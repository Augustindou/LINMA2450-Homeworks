using sub_problems: createSubProblem


function dantzig_wolfe(generators, periods, generators_data, demand)
    
    G = length(generators)
    T = length(periods)

    P = Dict(g => [] for g in generators)
    Z = Dict(g => [] for g in generators)
    N_TOT = 0

    # todo liste de P et z
    
    # choose initial d0
    d = # TODO

    while true
        generator_count = 0

        for g in generators
            # find P, U, V, W that solves problem 13 with d^k with objective value z^k
            subproblem = createSubProblem(generators_data[g], periods, d[G:G+T])
            optimize!(subproblem)

            Zg = objective_value(subproblem)
            Pg = JuMP.value.(prod)
            
            if Zg == d
                generator_count = generator_count+1
            else
                # add (P,U,V,W) to B
                N_TOT += 1
                push!(Z[g], Zg)
                push!(P[g], Pg)
            end
        end

        if generator_count == G
            break
        end

        # find d^k+1 and l^k+1 that solve problem 11
        A = get_A(P, G, T, generators, N_TOT)
        h = get_h(demand, G, T)
        c = get_c(Z, G, generators, N_TOT)
        
        d = # TODO
    end
end


function get_A(P, G, T, generators, N_TOT)
    A = zeros(G + T, N_TOT)
    pos = 1
    for g in 1:G
        N = length(P[generators[g]])
        A[g, pos:pos+N] .= 1
        
        for i in 1:N
            A[G+1:G+T, pos+i-1] = P[generators[g]][i]
        end

        pos += N
    end
    
    return A
end

function get_h(D, G, T)
    h = ones(G+T)
    h[G+1:G+T] = D

    return h
end

function get_c(Z, G, generators, N_TOT)
    c = zeros(N_TOT)
    pos = 1
    
    for g in 1:G
        N = length(Z[generators[g]])
        c[pos:pos+N] = Z[generators[g]]
        pos += N
    end

    return c
end
