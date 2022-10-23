using AlgebraOfGraphics
using CairoMakie
using Chain: @chain
using DataFrames

include(joinpath(pwd(),"..", "src", "helpers.jl"))
include(joinpath(pwd(),"..", "src", "read-data.jl"))

questions = read_questions_raw(joinpath(data_folder_path, "questions.csv"))

meat_washing_data_url = "https://gist.githubusercontent.com/Hasnep/8c60d7c27bbc9323763d6059c24fff76/raw/25c70005d3a86a82c6187c6dca4cecad2622a0c6/RaguseaMeatWashingSurveyResponsesRaw.csv"
meat_washing_file_path = joinpath(data_folder_path, "meat-washing.csv")
download_if_needed(meat_washing_data_url, meat_washing_file_path)
meat_washing_raw = read_meat_washing_raw(meat_washing_file_path);

# Clean the data

meat_washing = @chain meat_washing_raw begin
    rename(questions...) # Fix column names
    transform(:country_residence => ByRow(clean_countries) => :country_residence)
    transform(:country_origin => ByRow(clean_countries) => :country_origin)
    transform(:do_regularly => ByRow(separate_do_regularly) => AsTable)
    ## Drop joke answers
    subset(:age => ByRow(a -> ismissing(a) || 5 <= a <= 120))
    subset(:household_size => ByRow(n -> ismissing(n) || 1 <= n <= 50))
    @aside println(first(_, 5))
end;

# # Let's understand the respondents

# @chain meat_washing begin
#     countmap(by = :country_residence)
#     sort(order(:n, rev = true))
#     first(10)
#     @df _ bar(:country_residence, :n; title = "Country of residence of respondents", xrotation = 45)
#     export_plot("country_of_residence")
# end;

# # ![Country of residence of respondents](country_of_residence.svg)

# @chain meat_washing begin
#     subset(:gender => ByRow(g -> ismissing(g) || g in ["Male", "Female", "Non-binary"]))
#     countmap(by = [:do_regularly_wash_hands, :gender])
#     groupby(:gender)
#     transform(:n => (x -> x ./ sum(x)) => :proportion)
#     transform(:do_regularly_wash_hands => ByRow(yes_or_no) => :do_regularly_wash_hands)
#     @df _ groupedbar(
#         :do_regularly_wash_hands,
#         :proportion;
#         group = :gender,
#         yformatter = formatter_percent(digits = 0),
#         title = "Do you regularly wash your hands when cooking, preparing and consuming food products?",
#         legend = :topleft,
#         ylims = (0, 1)
#     )
#     export_plot("regularly_wash_hands_by_gender")
# end;

# # ![Country of residence of respondents](regularly_wash_hands_by_gender.svg)

# # We only want to consider countries with more than 100 data points
# top_countries = @chain meat_washing begin
#     countmap(by = :country_residence)
#     subset(:n => ByRow(>(100)))
#     _.country_residence
# end

# @chain meat_washing begin
#     dropmissing(:country_residence)
#     subset(:country_residence => ByRow(∈(top_countries)))
#     countmap(by = [:do_regularly_wash_hands, :country_residence])
#     groupby(:country_residence)
#     transform(:n => (x -> x ./ sum(x)) => :proportion)
#     subset(:do_regularly_wash_hands)
#     sort(order(:proportion, rev = true))
#     @df _ bar(
#         :country_residence,
#         :proportion;
#         yformatter = formatter_percent(digits = 0),
#         title = "Do you regularly wash your hands when cooking,\n preparing and consuming food products?",
#         legend = false,
#         xrotation = 45
#     )
#     export_plot("regularly_wash_hands_by_country")
# end;

# # ![Country of residence of respondents](regularly_wash_hands_by_country.svg)

# @chain meat_washing begin
#     dropmissing(:age)
#     dropmissing(:gender)
#     subset(:gender => ByRow(∈(["Male", "Female", "Non-binary"])))
#     @df _ histogram(
#         :age;
#         group = :gender,
#         xscale = :log10,
#         normalize = :pdf,
#         yformatter = formatter_percent(digits = 0),
#         legend = false,
#         xlabel = "Age",
#         title = "Which ages wash their hands the most?",
#         layout = (3, 1)
#     )
#     export_plot("regularly_wash_hands_by_age")
# end;

# # ![Which ages wash their hands the most?](regularly_wash_hands_by_age.svg)

# using Statistics: mean, std
# using Distributions: LogNormal# , plot
# @chain meat_washing begin
#     dropmissing(:age)
#     dropmissing(:gender)
#     subset(:gender => ByRow(∈(["Male", "Female", "Non-binary"])))
#     transform(:age => ByRow(log) => :log_age)
#     groupby(:gender)
#     combine(:log_age => mean => :mean_log_age, :log_age => std => :std_log_age)
#     transform([:mean_log_age, :std_log_age] => ByRow(LogNormal) => :distribution)
#     plot(_.distribution)
#     ##  @df _ plot(:distribution, group = :gender)
# end

# @chain meat_washing begin
#     dropmissing(:household_size)
#     @df _ histogram(
#         :household_size;
#         bins = range(1, maximum(:household_size), step = 1),
#         legend = false,
#         xlabel = "Household size"
#         ## title = "What is your age?",
#     )
# end

# @chain meat_washing begin
#     dropmissing(:prep_often)
#     countmap(by = :prep_often)
#     transform(:n => (x -> x ./ sum(x)) => :proportion)
#     @df _ bar(
#         :prep_often,
#         :proportion;
#         yformatter = formatter_percent(digits = 0),
#         title = "How often do you prepare a meal in your household?",
#         legend = false,
#         xrotation = 45,
#         ylims = (0, 1)
#     )
#     export_plot("prep_often_histogram")
# end;

# # ![Which genders wash their hands the most?](prep_often_histogram.svg)
