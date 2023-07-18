#
# Author: initkfs 2023
#
module DietOptimization

using JuMP

import DataFrames, HiGHS, CSV

function run()

    foodDataPath = "$(@__DIR__)/foods.csv"
    @assert isfile(foodDataPath)

    foods = CSV.read(foodDataPath, DataFrames.DataFrame)

    nutrientsLimitsPath = "$(@__DIR__)/limits.csv"
    @assert isfile(nutrientsLimitsPath)
    limits = CSV.read(nutrientsLimitsPath, DataFrames.DataFrame)

    model = Model(HiGHS.Optimizer)
    set_silent(model)

    @variable(model, x[foods.name] >= 0)

    foods.x = Array(x)

    @objective(model, Min, sum(foods.cost .* foods.x))

    @constraint(
        model,
        [row in eachrow(limits)],
        row.min <= sum(foods[!, row.nutrient] .* foods.x) <= row.max,
    )

    optimize!(model)
    solution_summary(model)

    table = Containers.rowtable(value, x; header=[:food, :quantity])
    solution = DataFrames.DataFrame(table)
    filter!(row -> row.quantity > 0.0, solution)
    println(solution)

end

end