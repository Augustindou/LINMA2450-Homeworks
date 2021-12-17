using Gurobi

VOLL = 1000

function createRMP(P, Z, demand, generators, T, G)
    rmp = Model(Gurobi.Optimizer)

    set_optimizer_attribute(rmp, "OutputFlag", 0)
    set_optimizer_attribute(rmp, "DualReductions", 0)

    @variable(rmp, 0 <= lambda[g in generators, i in 1:length(P[g])])
    @variable(rmp, 0 <= spos[i in 1:T])
    @variable(rmp, 0 <= sneg[i in 1:T])
    @variable(rmp, lambda_sum[g in generators])
    @variable(rmp, lambda_P[t in 1:T])

    @objective(rmp, Min, sum(sum(-lambda[g, i]*Z[g][i] for i in 1:length(Z[g])) for g in generators) + sum(spos[t] + sneg[t] for t in 1:T)*VOLL)

    # sum_i lambda_i, g = 1 for all g 
    for g in generators
        @constraint(rmp, lambda_sum[g] == sum(lambda[g, i] for i in 1:length(P[g])))
    end
    @constraint(rmp, lambda_dual, lambda_sum .== ones(G))


    # market clearing
    for t in 1:T 
        @constraint(rmp, sum(sum(lambda[g, i]*P[g][i][t] for i in 1:length(P[g])) for g in generators) == lambda_P[t])
    end 

    @constraint(rmp, costs, lambda_P .== demand .+ spos .- sneg )

    optimize!(rmp)

    # print(JuMP.raw_status(rmp))

    # print("--------------------------------------\n")
    # print(JuMP.value.(lambda))
    # print("--------------------------------------\n")
    costs = JuMP.dual.(costs)
    d     = JuMP.dual.(lambda_dual)
    z     = JuMP.objective_value(rmp)

    return costs, d, z
end