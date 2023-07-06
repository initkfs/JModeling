module SimpleProductOptimization

using JuMP, Clp, Test

#= 
Product manufacturing cost
Product №1 - 2.0, 1.0
Product №2 - 1.0, 1.0

Productive reserves
Resource 1 - 10.0
Resource 2 - 7.0

Profit
Product №1 - 6.0
Product №2 - 4.0

The goal is to maximize profit
=#

function run()

    model = Model(Clp.Optimizer)

    @variable(model, product1 >= 0)
    @variable(model, product2 >= 0)

    @objective(model, Max, 6product1 + 4product2)

    @constraint(model, c1, 2product1 + product2 <= 10)
    @constraint(model, c2, product1 + product2 <= 7)

    optimize!(model)

    product1Value = value(product1)
    product2Value = value(product2)
    maxProfit = objective_value(model)

    if termination_status(model) != OPTIMAL
        error("The model was not solved correctly.")
    end

    @test product1Value ≈ 3
    @test product2Value ≈ 4
    @test maxProfit ≈ 34
end

end