import CSV
using Chain: @chain
using DataFrames

include("helpers.jl")

function clean_countries(country_name)
    @chain country_name begin
        replace("United Kingdom of Great Britain and Northern Ireland" => "UK")
        replace("United States of America" => "USA")
    end
end
clean_countries(::Missing) = missing

levels_do_regularly = Dict(
    :do_regularly_cook_to_required_temperature => "Cook to required temperature (such as 165ºF for poultry)",
    :do_regularly_separate_cutting_boards =>
        "Use different or just-cleaned cutting boards for each product (such as raw meat/poultry/produce)",
    :do_regularly_separate_raw_meat => "Separate raw meat, poultry and seafood from ready-to-eat food products",
    :do_regularly_thaw_food => "Thaw foods in refrigerator or in cool water",
    :do_regularly_wash_cutting_board => "Wash cutting board(s) with soap and water or bleach",
    :do_regularly_wash_hands => "Wash my hands with soap and water",
)
separate_do_regularly(s) = separate(s; levels = values(levels_do_regularly), level_names = keys(levels_do_regularly))


# Read data
function get_meat_washing()
    questions = @chain "questions.csv" begin
        joinpath(data_folder_path, _)
        CSV.File()
        DataFrame()
    end

    meat_washing = @chain "meat-washing.csv" begin
        joinpath(data_folder_path, _)
        CSV.File(header = 2)
        DataFrame()
        rename(questions.raw_name .=> questions.column_name) # Fix column names
        transform(:country_residence => ByRow(clean_countries) => :country_residence)
        transform(:country_origin => ByRow(clean_countries) => :country_origin)
        transform(:do_regularly => ByRow(separate_do_regularly) => AsTable)
        filter(:age => (a -> ismissing(a) || 5 <= a <= 120), _) # Drop joke answers
        filter(:household_size => (n -> ismissing(n) || 1 <= n <= 50), _) # Drop joke answers and nonsensical answers
    end
end
