import CSV
using Chain: @chain
using DataFrames

function clean_countries(country_name)
    @chain country_name begin
        replace("United Kingdom of Great Britain and Northern Ireland" => "UK")
        replace("United States of America" => "USA")
    end
end
clean_countries(::Missing) = missing

levels_do_regularly = Dict(
    :do_regularly_cook_to_required_temperature => "Cook to required temperature (such as 165ºF for poultry)",
    :do_regularly_separate_cutting_boards => "Use different or just-cleaned cutting boards for each product (such as raw meat/poultry/produce)",
    :do_regularly_separate_raw_meat => "Separate raw meat, poultry and seafood from ready-to-eat food products",
    :do_regularly_thaw_food => "Thaw foods in refrigerator or in cool water",
    :do_regularly_wash_cutting_board => "Wash cutting board(s) with soap and water or bleach",
    :do_regularly_wash_hands => "Wash my hands with soap and water",
)
separate_do_regularly(s) = separate(s; levels = values(levels_do_regularly), level_names = keys(levels_do_regularly))

# Raw data functions

read_questions_raw(file_path) = @chain file_path begin
    CSV.File()
    Dict(_.raw_name .=> _.column_name)
end
read_meat_washing_raw(file_path) = @chain file_path begin
    CSV.File(header = 2)
    DataFrame()
end
