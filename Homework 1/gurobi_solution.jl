using JuMP, Gurobi, JSON, LinearAlgebra

DATA_PATH = "small.json"
data = JSON.parsefile(DATA_PATH)


# ---------------------------------------------------------
# Gurobi Solution
# ---------------------------------------------------------
# create model
model = Model(Gurobi.Optimizer)

# variables for easy access
N = length(data["N"])
utility = data["utility"] # a_i
weight = data["weight"] # c_i
b = data["b"] # b

# model the model
@variable(model, x[1:N] >= 0, Int)
@objective(model, Max, sum(x[i] * utility[i] for i = 1:N))
@constraint(model, sum(x[i] * weight[i] for i = 1:N) <= b)

# set parameters to 0
set_optimizer_attribute(model, "Presolve", 0)
set_optimizer_attribute(model, "Heuristics", 0)
set_optimizer_attribute(model, "Cuts", 0)


print(model)
optimize!(model)
@show termination_status(model)
@show primal_status(model)
@show dual_status(model)
@show objective_value(model)
JuMP.value.(x)