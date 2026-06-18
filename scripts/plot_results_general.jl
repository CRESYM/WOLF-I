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
df_filtered = filter(row -> row.jpod == 3 && row.iinp != "f" && row.symvar != "KD", df_results)

# --- New grid: n_symvar rows, 2 columns (P, Q) ---
unique_iinp = unique(df_filtered.iinp)
unique_iinp = sort(unique_iinp, by = var -> get(process_results.iinp_labels, var, string(var)))
unique_iout = unique(df_filtered.iout) |> sort
unique_symvar = unique(df_filtered.symvar)
unique_symvar = sort(unique_symvar, by = var -> get(process_results.symvar_labels, var, string(var)))
nrows = length(unique_symvar)
ncols = length(unique_iout)
fig = Figure(size = (520, 200 * nrows))

palette = Makie.wong_colors()
iinp_color_map = Dict(iinp => palette[mod1(i, length(palette))] for (i, iinp) in enumerate(unique_iinp))


# --- Prepare for a common legend ---
line_handles = Vector{Any}()
line_labels = String[]    
for (rowidx, symvar) in enumerate(unique_symvar)
    df_symvar = filter(row -> row.symvar == symvar, df_filtered)
    # Set xticks conditionally for each axis
    if symvar == "va"
        xticks_val = (0:π/2:2π, ["0", "π/2", "π", "3π/2", "2π"])
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

    for (colidx, iout) in enumerate(unique_iout)
        ax = Axis(
            fig[rowidx, colidx],
            title = rowidx == 1 ? get(iout_labels, iout, iout) : "",
            titlesize = 18,
            xlabel = get(symvar_labels, symvar, symvar),
            xlabelsize = 18,
            ylabel = colidx == 1 ? "ES" : "",
            ylabelsize = 18,
            limits = (nothing, (-1.2, 1.2)),
            xticklabelsize = 16,
            yticklabelsize = 16,
            xticks = xticks_val,
            xscale = use_log_scale ? log10 : identity,
        )

        # Filter rows for this iout
        subdf = filter(row -> row.iout == iout, df_symvar)
        for iinp_val in unique_iinp
            gdf_filtered = filter(row -> row.iinp == iinp_val, subdf)
            color = iinp_color_map[iinp_val]
            l = lines!(
                ax,
                abs.(gdf_filtered.symvalue),
                imag.(gdf_filtered.sensivalue),
                color = color,
                linewidth = 4,
                label = get(iinp_labels, iinp_val, iinp_val)
            )
            # Collect legend entries from first subplot only
            if rowidx == 1 && colidx == 1
                push!(line_handles, l)
                push!(line_labels, get(process_results.iinp_labels, iinp_val, iinp_val))
            end
            
        end

    end
end

# Add a single legend for iinp (color meaning) at the bottom of the figure
if !isempty(line_handles)
    leg = Legend(fig, line_handles, line_labels, framevisible = false, halign = :center, orientation = :vertical, nbanks = 2, labelsize = 18)
    fig[nrows+1, 1:ncols] = leg
end

save("figures/all_sensi_3.png", fig)