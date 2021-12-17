using JuMP

include("sub_problems.jl")
include("restricted_master_problem.jl")


function dantzig_wolfe(generators, periods, generators_data, demand, max_iter=150)
    
    G = length(generators)
    T = length(periods)

    P = Dict(g => [] for g in generators)
    Z = Dict(g => [] for g in generators)
    N_TOT = 0

    # todo liste de P et z
    
    # choose initial d0
    costs = 20*ones(T) # TODO
    d = Dict(g => Inf for g in generators)

    UB = Inf 
    LB = -Inf

    print("UB, LB = ")
    print(UB)
    print(", ")
    println(LB)

    generator_count = 0

    k = 0

    while k <= max_iter
        k += 1

        print("k = ")
        println(k)

        LBk = 0
        for g in generators
            # find P, U, V, W that solves problem 13 with d^k with objective value z^k
            Zg, Pg = createSubProblem(generators_data[g], periods, costs)

            if Zg == d[g] && k > 1
                generator_count += 1
            end
            # add (P,U,V,W) to B
            N_TOT += 1
            push!(Z[g], Zg)
            push!(P[g], Pg)

            LBk -= Zg
            
        end

        LBk += sum(costs[t]*demand[t] for t in 1:T)

        LB = max(LB, LBk)

        # if generator_count == G
        #     break
        # end

        print("generator count = ")
        println(generator_count)

        # find d^k+1 and l^k+1 that solve problem 11
        costs, d, z_rmp = createRMP(P, Z, demand, generators, T, G)
        print(costs)
        print(z_rmp)

        UB = min(UB, z_rmp)

        if UB == LB
            break 
        end

        print("UB, LB = ")
        print(UB)
        print(", ")
        println(LB)

        if k == 2
            break
        end

    end

    println(UB)
    println(LB)
    println(generator_count)
    

    return "bite"
end
