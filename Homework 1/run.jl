using JSON

include("gurobi_solution.jl")

DATA_PATH = "small.json"
data = JSON.parsefile(DATA_PATH)

# variables for easy access
utilities = data["utility"] # a_i
weights = data["weight"] # c_i
b = data["b"] # b

# run gurobi
println("----------------------")
println("------- Gurobi -------")
println("----------------------")
println(gurobi_knapsack(utilities, weights, b))
