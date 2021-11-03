function greedy_knapsack(utilities, weights, b)
    N = length(utilities)
    ratios = [utilities[i]/weights[i] for i = 1:N]
    total_weight = 0
    total_utility = 0
    x = zeros(N)
    
    sorted_idx = sortperm(ratios, rev=true)
    
    for i = sorted_idx
        y = floor((b - total_weight) / weights[i])
        if y > 0
            x[i] += y
            total_weight += y * weights[i]
            total_utility += y * utilities[i]
        end
    end
    return total_utility, x
end