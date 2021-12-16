using JSON

include("dantzig_wolfe.jl")


function run(data_path)
    data = JSON.parsefile(data_path)

    generators = data["generators"]
    demand = data["demand"]
    generators_data = data["generators_data"]
    periods = data["periods"]

    res = dantzig_wolfe(generators, periods, generators_data, demand)

    print(res)
end


run("2015-06-01_hw.json")