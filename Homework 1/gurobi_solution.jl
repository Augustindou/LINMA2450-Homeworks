using JuMP, Gurobi

# ---------------------------------------------------------
# Gurobi Solution
# ---------------------------------------------------------

function gurobi_knapsack(utilities, weights, b)
    # create model
    model = Model(Gurobi.Optimizer)
    MOI.set(model, MOI.Silent(), true)
    N = length(utilities)
    
    # model the model
    @variable(model, x[1:N] >= 0, Int)
    @objective(model, Max, sum(x[i] * utilities[i] for i = 1:N))
    @constraint(model, sum(x[i] * weights[i] for i = 1:N) <= b)
    
    # set parameters to 0
    set_optimizer_attribute(model, "Presolve", 0)
    set_optimizer_attribute(model, "Heuristics", 0)
    set_optimizer_attribute(model, "Cuts", 0)
    
    # run optimization
    optimize!(model)
    
    # returning results
    objective_value(model), JuMP.value.(x)
end