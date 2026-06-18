using Symbolics
using JLD2

# file1 = jldopen("results/results_x12.jld2", "r")
# file2 = jldopen("results/results_x.jld2", "r")
file1 = jldopen("results/results_2.jld2", "r")
file2 = jldopen("results/results_2_x.jld2", "r")
# file4 = jldopen("results/results_xf2.jld2", "r")
# file5 = jldopen("results/results_kHf.jld2", "r")

vars = [:λres, :ζ, :λcheck, :ζcheck, :λplot, :ζplot]

function concat_dicts(dicts::Vector)
    merged = Dict()
    for d in dicts
        merge!(merged, d)   # union of keys, last wins if duplicate
    end
    return merged
end


merged_data = Dict()
for v in vars
    name = String(v)   # convert Symbol -> String
    d1, d2 = file1[name], file2[name] #d1, d2, d3, d4, d5 = file1[name], file2[name], file3[name], file4[name], file5[name]
    merged_data[v] = concat_dicts([d1, d2]) #[d1, d2, d3, d4, d5]
end

close(file1)
close(file2)
# close(file3)
# close(file4)
# close(file5)

# Example
ζplot = merged_data[:ζplot]
λcheck = merged_data[:λcheck]
λplot = merged_data[:λplot]
ζ = merged_data[:ζ];

save("results/merged_results_2.jld2", merged_data)
