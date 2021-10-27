function greedy_knapsack(utilities, weights, b)
    N = length(utilities)
    item_value = [utilities[i]/weights[i] for i = 1:N]
    total_weight = 0
    total_utility = 0
    x = zeros(N)
    
    sorted_idx = sortperm(item_value, rev=true)
    
    for i = sorted_idx
        while total_weight + weights[i] <= b
            x[i] += 1
            total_weight += weights[i]
            total_utility += utilities[i]
        end
    end
    total_utility, x
end