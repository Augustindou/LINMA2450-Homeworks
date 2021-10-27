using JSON

include("gurobi_solution.jl")
include("greedy_algorithm.jl")
include("dynamic_programming_solution.jl")

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

println("\n")

# run greedy
println("----------------------")
println("------- Greedy -------")
println("----------------------")
println(greedy_knapsack(utilities, weights, b))

println("\n")

# run dynamic programming
println("----------------------")
println("--------- DP ---------")
println("----------------------")
println(dynamic_knapsack(utilities, weights, b))
