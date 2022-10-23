using Chain: @chain
using DataFrames
using AlgebraOfGraphics
using CairoMakie

include("helpers.jl")
include("read-data.jl")

meat_washing = get_meat_washing()

# Plots
@chain meat_washing begin
    countmap(by = :country_residence)
    sort(order(:n, rev = true))
    first(10)
    data(_) *
    mapping(:country_residence => "Country of residence", :n => "Number of respondants") *
    mapping(color = :country_residence => "Country of residence") *
    visual(BarPlot)
    draw(axis = (width = 225, height = 225))
end

@chain meat_washing begin
    data(_) *
    frequency() *
    mapping(:country_residence => "Country of residence") *
    mapping(color = :country_residence => "Country of residence") *
    visual(BarPlot)
    draw(axis = (width = 225, height = 225))
end
