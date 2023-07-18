#
# Author: initkfs 2023
#
module StaticProductOptimization

using JuMP, Clp, Test

#= 
Profit
Product1 = 56, Product2 = 40

Details,Product1, Product2, Stock
1,8,4,1350
2,4,12,1600
3,4,4,760
4,1,0,140
5,0,1,120

Weekly production >=100
Profit -> max
=#

function run()

    model = Model(Clp.Optimizer)

    @variable(model, x1 >= 0)
    @variable(model, x2 >= 0)

    @objective(model, Max, 56x1 + 40x2)

    @constraint(model, c1, 8x1 + 4x2 <= 1350)
    @constraint(model, c2, 4x1 + 12x2 <= 1600)
    @constraint(model, c3, 4x1 + 4x2 <= 760)
    @constraint(model, c4, x1 <= 140)
    @constraint(model, c5, x2 <= 120)
    @constraint(model, c6, x1 + x2 >= 100)

    optimize!(model)

    if termination_status(model) != OPTIMAL
        error("The model was not solved correctly.")
    end

    x1Value = value(x1)
    x2Value = value(x2)
    maxProfit = objective_value(model)

    @test x1Value ≈ 140
    @test x2Value ≈ 50
    @test maxProfit ≈ 9840

    report = lp_sensitivity_report(model)

    x1ProfitLo, x1ProfitHi = report[x1]
    x2ProfitLo, x2ProfitHi = report[x2]

    @test x1ProfitLo ≈ -16
    @test isinf(x1ProfitHi)
    @test x2ProfitLo ≈ -40
    @test x2ProfitHi ≈ 16

    x1ReducedCost = reduced_cost(x1)
    x2ReducedCost = reduced_cost(x2)

    @test x1ReducedCost ≈ 0
    @test x2ReducedCost ≈ 0

end

end