function dynamic_knapsack(utilities, weights, b)
    N = length(utilities)
    b = Int(b)

    objectives = zeros(b+1)
    x = zeros(b+1, N)

    for i = 2:b+1
        objectives[i] = objectives[i-1]
        x[i,:] = x[i-1,:]
        available_size = i-1

        for j = 1:N
            # only check objects that can fit in the sack
            if available_size >= weights[j]
                # compute the utility if we add object j
                current_utility = utilities[j] + objectives[i - weights[j]]

                # update if utility is better
                if current_utility > objectives[i]
                    objectives[i] = current_utility
                    y = copy(x[i-weights[j],:])
                    y[j] += 1
                    x[i,:] = y
                end

            end
        end
    end

    return objectives[end], x[end,:]
end