using Plots
using JLD2
using Symbolics # To import symbolics expressions with JLD2.load
using DataFrames
using Statistics
using CairoMakie
using WGLMakie
WGLMakie.activate!()

using SymbolicES

# Load results
results = JLD2.load("results/results_1_shiftbus3.jld2");
df_results = dict_to_df(results["ζplot"])
df_filtered = filter(row -> row.jpod == 3 && row.iinp == "f" && row.symvar != "KD" && row.symvar != "x" && row.symvar != "vm", df_results)

# --- New grid: n_symvar rows, 2 columns (P, Q) ---
unique_iinp = unique(df_filtered.iinp)
unique_iinp = sort(unique_iinp, by = var -> get(process_results.iinp_labels, var, string(var)))
unique_iout = unique(df_filtered.iout) |> sort
unique_symvar = unique(df_filtered.symvar)
unique_symvar = sort(unique_symvar, by = var -> get(process_results.symvar_labels, var, string(var)))
nrows = length(unique_symvar)
ncols = length(unique_iout)
fig = Figure(size = (520, 250))

palette = Makie.wong_colors()
iout_color_map = Dict(iout => palette[mod1(i, length(palette))] for (i, iout) in enumerate(unique_iout))

line_handles = Vector{Any}()
line_labels = String[]
for (i, symvar) in enumerate(unique_symvar)
    # Set xticks conditionally for each axis
    if symvar == "va"
        xticks_val = (0:π:2π, ["0", "π", "2π"])
    elseif symvar == "kH"  # Inertia Ratio
        # Custom ticks for logarithmic scale - more intermediate values
        xticks_val = ([0.1, 1.0, 10.0], ["0.1", "1.0", "10.0"])
    elseif symvar == "x"   # Line Impedance
        # Custom ticks for logarithmic scale
        xticks_val = ([0.015, 0.15, 1.5], ["0.015", "0.15", "1.5"])
    else
        xticks_val = Makie.automatic
    end 

    # Determine if logarithmic scale should be used
    use_log_scale = symvar in ["kH", "x"]  # Inertia Ratio or Line Impedance

    ax = Axis(
        fig[1, i], 
        title = " ", 
        titlesize = 18,
        xlabel = get(symvar_labels, symvar, symvar), 
        xlabelsize = 18,
        ylabel = i == 1 ? "ES" : "", 
        xticklabelsize = 16,
        yticklabelsize = 16,
        limits = (nothing, (-0.0025, 0.0025)),
        xticks = xticks_val,
        xscale = use_log_scale ? log10 : identity,
    )
    
    # Filter for this subplot
    subdf = filter(row -> row.symvar == symvar, df_filtered)

    # Loop over each output group
    for (j, gdf) in enumerate(groupby(subdf, :iout))
        iout_val = gdf.iout[1]
        l = lines!(
            ax,
            abs.(gdf.symvalue),
            real.(gdf.sensivalue),
            color = iout_color_map[iout_val],
            linewidth = 4,
            label = get(iout_labels, iout_val, iout_val)
        )
        
        # Collect legend entries only from the first subplot
        if i == 1
            push!(line_handles, l)
            push!(line_labels, get(iout_labels, iout_val, iout_val))
        end
    end

end

# Add legend if we have line objects
if !isempty(line_handles)
    leg = Legend(fig, line_handles, line_labels, framevisible = false, halign = :center, orientation = :vertical, nbanks = 1, labelsize = 18)
    fig[2, 1:length(unique_symvar)] = leg
end

display(fig)

save("figures/results_3_f.png", fig)