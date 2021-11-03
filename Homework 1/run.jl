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
    algorithms = [("Greedy", greedy_knapsack), ("DP", dynamic_knapsack), ("Gurobi Solver", gurobi_knapsack)]

    results = Dict("Greedy"=>[], "DP"=>[], "Gurobi Solver"=>[])

    for (name, algorithm) = algorithms
        for data_path = data_paths
            data = JSON.parsefile(data_path)
    
            # variables for easy access
            utilities = data["utility"] # a_i
            weights = data["weight"] # c_i
            b = data["b"] # b

            # launching the algorithm on the dataset
            t = @elapsed z, x = algorithm(utilities, weights, b)

            # Saving the results
            results[name] = push!(results[name], (t, z)) 
            
            # Displaying the results
            println("Results for "*name*" on dataset "*data_path*" : \n z = "*string(Int(z))*"\n Computed in "*string(t)*" seconds\n")
        end
    end

    return results
end


test_file("small.json")

println("\n\n==========================================\n")

print(time_analysis(["small.json", "medium.json", "large1.json", "large2.json"]))