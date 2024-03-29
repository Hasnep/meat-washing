import Downloads

# File paths
data_folder_path = joinpath(pwd(), "..","data")
output_folder_path = joinpath(pwd(),"..", "build")

# Data download
download_if_needed(url, file_path) = isfile(file_path) ? nothing : Downloads.download(url, file_path)

"""
Return an anonymous function that formats a number as a percentage with a specified level of accuracy.
"""
formatter_percent(; digits) = (x -> string(round(100 * x, digits = digits)) * "%")

"""
Convert a delimited string of items into a list of boolean values showing occurrence.
"""
separate(s; levels, level_names) = (; zip(level_names, occursin.(levels, s))...)
separate(::Missing; levels, level_names) = (; zip(level_names, repeat([missing], length(levels)))...)

"""
Count the occurrences of unique values in a column in a DataFrame.
"""
function countmap(df::DataFrame; by)
    @chain df begin
        dropmissing(by)
        groupby(by)
        combine(nrow => :n)
    end
end

"""Convert a boolean to "Yes" or "No"."""
yes_or_no(x) = x ? "Yes" : "No"

function string_wrap(s::String, width::Integer)
    output = ""
    for i in 1:width:length(s)
        output *= s[i:(i+width-1)] * "\n"
    end
    return output
end

# # Plots
# function export_plot(p, plot_name)
#     exported_file_path = joinpath(output_folder_path, plot_name * ".svg")
#     savefig(p, exported_file_path)
#     return p
# end
