using Plots
using StatsPlots
using Chain: @chain
using DataFrames

include("helpers.jl")
include("read-data.jl")

meat_washing = get_meat_washing()

# Plots
@chain meat_washing begin
    countmap(by = :country_residence)
    sort(order(:n, rev = true))
    first(10)
    @df _ bar(:country_residence, :n; title = "Country of residence of respondents", xrotation = 45)
end

@chain meat_washing begin
    countmap(by = :country_origin)
    sort(order(:n, rev = true))
    first(10)
    @df _ bar(:country_origin, :n; title = "Country of origin of respondents", xrotation = 45)
end

@chain meat_washing begin
    filter(:gender => (g -> !ismissing(g) && g ∈ ("Male", "Female", "Non-binary")), _)
    countmap(by = [:do_regularly_wash_hands, :gender])
    groupby(:gender)
    transform(:n => (x -> x ./ sum(x)) => :proportion)
    transform(:do_regularly_wash_hands => ByRow(yes_or_no) => :do_regularly_wash_hands)
    @df _ groupedbar(
        :do_regularly_wash_hands,
        :proportion;
        group = :gender,
        yformatter = formatter_percent(digits = 0),
        title = "Do you regularly wash your hands when cooking, preparing and consuming food products?",
        legend = :topleft,
        ylims = (0, 1),
    )
end

top_countries = @chain meat_washing begin
    countmap(by = :country_residence)
    filter(:n => n -> n > 100, _)
    _.country_residence
end

@chain meat_washing begin
    dropmissing(:country_residence)
    filter(:country_residence => x -> x ∈ top_countries, _)
    countmap(by = [:do_regularly_wash_hands, :country_residence])
    groupby(:country_residence)
    transform(:n => (x -> x ./ sum(x)) => :proportion)
    filter(r -> r.do_regularly_wash_hands, _)
    sort(order(:proportion, rev = true))
    @df _ bar(
        :country_residence,
        :proportion;
        yformatter = formatter_percent(digits = 0),
        title = "Do you regularly wash your hands when cooking,\n preparing and consuming food products?",
        legend = false,
        xrotation = 45,
    )
end

@chain meat_washing begin
    dropmissing(:age)
    dropmissing(:gender)
    filter(:gender => (g -> g ∈ ("Male", "Female", "Non-binary")), _)
    @df _ histogram(
        :age;
        group = :gender,
        #   xscale = :log10,
        normalize = :pdf,
        yformatter = formatter_percent(digits = 0),
        legend = false,
        xlabel = "Age",
        # title = "What is your age?",
        layout = (3, 1),
    )
end

using Statistics: mean, std
using Distributions: LogNormal, plot!
@chain meat_washing begin
    dropmissing(:age)
    dropmissing(:gender)
    filter(:gender => (g -> g ∈ ("Male", "Female", "Non-binary")), _)
    transform(:age => ByRow(log) => :age)
    groupby(:gender)
    combine(:age => mean, :age => std)
    transform([:age_mean, :age_std] => ByRow(LogNormal) => :distribution)
    @df _ plot!(:distribution, group = :gender)
end

@chain meat_washing begin
    dropmissing(:household_size)
    @df _ histogram(
        :household_size;
        bins = range(1, maximum(:household_size), step = 1),
        legend = false,
        xlabel = "Household size",
        # title = "What is your age?",
    )
end

@chain meat_washing begin
    dropmissing(:prep_often)
    countmap(by = :prep_often)
    transform(:n => (x -> x ./ sum(x)) => :proportion)
    @df _ bar(
        :prep_often,
        :proportion;
        yformatter = formatter_percent(digits = 0),
        title = "How often do you prepare a meal in your household?",
        legend = false,
        xrotation = 45,
    )
end
