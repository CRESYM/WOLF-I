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
df_results = dict_to_df(results["λplot"])
rename!(df_results, :sensivalue => :eigenvalue)

df_filtered = filter(row -> row.iinp == "v" && row.iout == "P" && row.symvar != "KD" && row.jpod == 3, df_results)

# Step 1 & 2: Normalize symvalue within each symvar group
# Group by symvar and calculate min/max for each group, then normalize
df_filtered = transform(groupby(df_filtered, :symvar), 
    :symvalue => (x -> begin
        min_val = minimum(real.(x))  # Get minimum of real part
        max_val = maximum(real.(x))  # Get maximum of real part
        # Normalize: (value - min) / (max - min)
        if max_val == min_val
            # Handle case where all values are the same
            zeros(length(x))
        else
            (real.(x) .- min_val) ./ (max_val - min_val)
        end
    end) => :symvalue_normalized
)

# Create the plot with larger fonts
fig = Figure(size = (420, 300))
ax = Axis(fig[1, 1], 
    xlabel = "Normalized Variable Value", 
    ylabel = "Mode Frequency (Hz)",
    xlabelsize = 18,
    ylabelsize = 18,
    xticklabelsize = 16,
    yticklabelsize = 16
)

# Get unique symvar values and sort by their labels alphabetically
unique_symvar = unique(df_filtered.symvar)
# Sort by the alphabetical order of their labels
unique_symvar = sort(unique_symvar, by = var -> get(process_results.symvar_labels, var, string(var)))
palette = Makie.wong_colors()

# Plot a line for each symvar
for (i, var) in enumerate(unique_symvar)
    # Filter data for this symvar
    var_data = filter(row -> row.symvar == var, df_filtered)
        
    # Extract x and y values (using imaginary part of eigenvalue)
    x_vals = var_data.symvalue_normalized
    y_vals = imag.(var_data.eigenvalue)/(2π)  # Convert to Hz
    
    # Get the proper label from symvar_labels, fallback to string(var) if not found
    var_label = get(process_results.symvar_labels, var, string(var))
    
    # Plot line
    lines!(ax, x_vals, y_vals, 
        color = palette[i], 
        linewidth = 4,
        label = var_label
    )
end

# Add legend at the bottom of the figure in 2 columns without box
Legend(fig[2, 1], ax, orientation = :horizontal, nbanks = 2, framevisible = false, labelsize = 18)

# Display the figure
fig

save("figures/eigen_parameters.png", fig)