
# Note that this is the subproblem for each generator g (so the "generators_data" corresponds to the data of a given generator g).
function createSubProblem(generators_data, periods, prices)
    # Extract relevant data
    startup_categories = 1:length(generators_data["startup"])
    pwl_points = 1:length(generators_data["piecewise_production"])

    sub_problem = Model(Gurobi.Optimizer)
    set_optimizer_attribute(sub_problem, "OutputFlag", 0)

    # Generators variables
    @variable(sub_problem, commit[t in periods], Bin)
    @variable(sub_problem, startup[t in periods], Bin)
    @variable(sub_problem, shutdown[t in periods], Bin)
    @variable(sub_problem, 0 <= prod[t in periods])
    @variable(sub_problem, delta[s in startup_categories, t in periods], Bin)
    @variable(sub_problem, cost[t in periods])
    @variable(sub_problem, 0 <= pwl_prod[l in pwl_points, t in periods] <= 1)
    @variable(sub_problem, total_cost)

    # Objective - maximize profit production cost
    @objective(sub_problem, Max,
        sum(prices[t] * (generators_data["power_output_minimum"] * commit[t] + prod[t]) for t in periods)
        - total_cost
    )

    @constraint(sub_problem,
        total_cost >= sum(cost[t] + generators_data["piecewise_production"][1]["cost"] * commit[t]
        + sum(delta[s, t] * generators_data["startup"][s]["cost"] for s in startup_categories)
        for t in periods)
    )

    # Generator constraints
    @constraint(sub_problem, Pmax_cons1[t in periods],  # Pmax when startup
        prod[t] <= (generators_data["power_output_maximum"]
        - generators_data["power_output_minimum"]) * commit[t]
        - max(generators_data["power_output_maximum"]
        - generators_data["ramp_startup_limit"], 0.0) * startup[t]
    )

    @constraint(sub_problem, Pmax_cons2[t in periods, t2 in periods; t2-t==1],  # Pmax when shutdown
    prod[t] <= (generators_data["power_output_maximum"]
    - generators_data["power_output_minimum"]) * commit[t]
    - max(generators_data["power_output_maximum"]
    - generators_data["ramp_shutdown_limit"], 0.0) * shutdown[t2]
    )

    @constraint(sub_problem, [t1 in periods, t2 in periods; t2-t1==1],
        startup[t2] - shutdown[t2] == commit[t2] - commit[t1]
    )

    @constraint(sub_problem, [t in periods; t==1],
    startup[t] - shutdown[t] == commit[t] - generators_data["unit_on_t0"]
    )

    @constraint(sub_problem, [t in periods; t==1],
    generators_data["unit_on_t0"] *
    (generators_data["power_output_t0"] - generators_data["power_output_minimum"])
    <= generators_data["unit_on_t0"] *
    (generators_data["power_output_maximum"] - generators_data["power_output_minimum"])
    - max(generators_data["power_output_maximum"] - generators_data["ramp_shutdown_limit"], 0) * shutdown[t]
    )

    # min up and down time
    @constraint(sub_problem, min_up_time[t in periods; t>=min(generators_data["time_up_minimum"], maximum(periods))],
        sum(startup[t2] for t2 in periods
        if (t2 >= t - min(generators_data["time_up_minimum"], maximum(periods))+1 && t2<=t))
            <= commit[t]
    )

    @constraint(sub_problem, min_down_time[t in periods; t>=min(generators_data["time_down_minimum"], maximum(periods))],
        sum(shutdown[t2] for t2 in periods
        if (t2 >= t - min(generators_data["time_down_minimum"], maximum(periods))+1 && t2<=t))
            <= 1 - commit[t]
    )

    if generators_data["unit_on_t0"] == 1  # min up time if generator is on in t=0
        @constraint(sub_problem, min_up_time0,
            sum(commit[t] - 1 for t in periods
            if (t <= min(generators_data["time_up_minimum"]-generators_data["time_up_t0"],
                maximum(periods)))) == 0
        )
    else  # min down time if generator is off in t=0
        @constraint(sub_problem, min_down_time0,
            sum(commit[t] for t in periods
            if (t <= min(generators_data["time_down_minimum"]-generators_data["time_down_t0"],
                maximum(periods)))) == 0
        )
    end

    # ramp constraints
    @constraint(sub_problem, rampup[t1 in periods, t2 in periods; t2-t1==1],
        prod[t2] - prod[t1] <= generators_data["ramp_up_limit"]
    )

    @constraint(sub_problem, rampupinit[t in periods; t==1],
        prod[t] - generators_data["unit_on_t0"] *
        (generators_data["power_output_t0"] - generators_data["power_output_minimum"])
        <= generators_data["ramp_up_limit"] # initial condition
    )

    @constraint(sub_problem, rampdown[t1 in periods, t2 in periods; t2-t1==1],
        - prod[t2] + prod[t1] <= generators_data["ramp_down_limit"]
    )

    @constraint(sub_problem, rampdowninit[t in periods; t==1],
        - prod[t] + generators_data["unit_on_t0"] *
        (generators_data["power_output_t0"] - generators_data["power_output_minimum"])
        <= generators_data["ramp_down_limit"] # initial condition
    )

    # must-run constraint
    @constraint(sub_problem, must_run[t in periods],
        commit[t] >= generators_data["must_run"]
    )

    # cost structure
    @constraint(sub_problem, [t in periods],
    startup[t] == sum(delta[s, t] for s in startup_categories)  # the startup must be of one category
    )

    @constraint(sub_problem, [t in periods, s in startup_categories; s < last(startup_categories) && t >= generators_data["startup"][s+1]["lag"]],
    delta[s, t] <= sum(shutdown[t2] for t2 in periods
    if (t2 <= t-generators_data["startup"][s]["lag"]) && (t2 >= t-generators_data["startup"][s+1]["lag"]+1)) # find the right startup category
    )

    @constraint(sub_problem,  # initial condition on the startup category
    0 == sum(
        sum(delta[s, t] for t in periods if t>=max(1, generators_data["startup"][s+1]["lag"] - generators_data["time_down_t0"] + 1)
        && t<=min(generators_data["startup"][s+1]["lag"] - 1, maximum(periods)))
        for s in startup_categories if s < last(startup_categories))
    )

    @constraint(sub_problem, [t in periods],
    prod[t] == sum(pwl_prod[l, t] * (generators_data["piecewise_production"][l]["mw"] - generators_data["piecewise_production"][1]["mw"]) for l in pwl_points)
    )

    @constraint(sub_problem, [t in periods],
    cost[t] == sum(pwl_prod[l, t] * (generators_data["piecewise_production"][l]["cost"] - generators_data["piecewise_production"][1]["cost"]) for l in pwl_points)
    )

    @constraint(sub_problem, [t in periods],
    commit[t] == sum(pwl_prod[l, t] for l in pwl_points)
    )

    optimize!(sub_problem)

    Zg = objective_value(sub_problem)
    Pg = JuMP.value.(prod)


    return Zg, Pg
end
