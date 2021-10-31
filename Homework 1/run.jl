using JSON

include("gurobi_solution.jl")
include("greedy_algorithm.jl")
include("dynamic_programming_solution.jl")

function test_file(data_path)
    data = JSON.parsefile(data_path)

    # variables for easy access
    utilities = data["utility"] # a_i
    weights = data["weight"] # c_i
    b = data["b"] # b
    
    # run gurobi
    println("----------------------")
    println("------- Gurobi -------")
    println("----------------------")
    @time println(gurobi_knapsack(utilities, weights, b))
    
    println("\n")
    
    # run greedy
    println("----------------------")
    println("------- Greedy -------")
    println("----------------------")
    @time println(greedy_knapsack(utilities, weights, b))
    
    println("\n")
    
    # run dynamic programming
    println("----------------------")
    println("--------- DP ---------")
    println("----------------------")
    @time println(dynamic_knapsack(utilities, weights, b))
end


function time_analysis(data_paths)
    gurobi = []
    greedy = []
    dp     = []
    for data_path = data_paths
        data = JSON.parsefile(data_path)

        # variables for easy access
        utilities = data["utility"] # a_i
        weights = data["weight"] # c_i
        b = data["b"] # b     

        # Compute results for each implementation
        #t = @elapsed z, x = gurobi_knapsack(utilities, weights, b)
        #gurobi = push!(gurobi, (t, z))
        t = @elapsed z, x = greedy_knapsack(utilities, weights, b)
        greedy = push!(greedy, (t, z))
        t = @elapsed z, x = dynamic_knapsack(utilities, weights, b)
        dp = push!(dp, (t, z))
    end

    return gurobi, greedy, dp
end


test_file("small.json")

println("\n\n==========================================\n")

print(time_analysis(["small.json", "medium.json", "large1.json", "large2.json"]))