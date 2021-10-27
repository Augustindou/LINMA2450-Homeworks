function dynamic_knapsack(utilities, weights, b)
    N = length(utilities)
    recursive_dynamic_knapsack(utilities, weights, b, zeros(N), 0)
end

function recursive_dynamic_knapsack(utilities, weights, b, x, total_utility)
    best_util = total_utility
    best_x = x
    N = length(utilities)
    for i = 1:N
        if b - weights[i] < 0
            continue
        else
            y = copy(x)
            y[i] += 1
            u, z = recursive_dynamic_knapsack(utilities, weights, b-weights[i], y, total_utility+utilities[i])
            if u > best_util
                best_util = u
                best_x = z
            end
        end
    end
    best_util, best_x
end