using CairoMakie
wong_colors = Makie.wong_colors() # Wong color palette

# Function to create a vector addition plot
function create_vector_plot!(ax, v1s, v2s, v3s, scaling_factors, start_point, title_text)
    # Apply scaling factors
    v1 = scaling_factors[1] * v1s
    v2 = scaling_factors[2] * v2s  
    v3 = scaling_factors[3] * v3s
    
    # Calculate the resulting vector (sum)
    v_result = v1 + v2 + v3
    
    # Set axis properties with consistent limits
    ax.aspect = 1
    ax.xlabel = "Real axis (s⁻¹)"
    ax.ylabel = "Imaginary axis (rad/s)"
    ax.title = title_text
    ax.xlabelsize = 16
    ax.ylabelsize = 16
    ax.titlesize = 22
    # Set consistent axis limits for all subplots
    xlims!(ax, -2, 1.2)
    ylims!(ax, 1.5, 4.5)
    
    # Plot individual vectors from the starting point (transparent)
    arrows2d!(ax, [start_point[1]], [start_point[2]], [v1s[1]], [v1s[2]], 
            color=wong_colors[1], alpha=0.4, shaftwidth=3, tipwidth=12, tiplength=12, lengthscale=1.0)
    arrows2d!(ax, [start_point[1]], [start_point[2]], [v2s[1]], [v2s[2]], 
            color=wong_colors[2], alpha=0.4, shaftwidth=3, tipwidth=12, tiplength=12, lengthscale=1.0)
    arrows2d!(ax, [start_point[1]], [start_point[2]], [v3s[1]], [v3s[2]], 
            color=wong_colors[3], alpha=0.4, shaftwidth=3, tipwidth=12, tiplength=12, lengthscale=1.0)

    # Plot scaled vectors (solid)
    arrows2d!(ax, [start_point[1]], [start_point[2]], [v1[1]], [v1[2]], 
            color=wong_colors[1], shaftwidth=3, tipwidth=12, tiplength=12, lengthscale=1.0)
    arrows2d!(ax, [start_point[1]], [start_point[2]], [v2[1]], [v2[2]], 
            color=wong_colors[2], shaftwidth=3, tipwidth=12, tiplength=12, lengthscale=1.0)
    arrows2d!(ax, [start_point[1]], [start_point[2]], [v3[1]], [v3[2]], 
            color=wong_colors[3], shaftwidth=3, tipwidth=12, tiplength=12, lengthscale=1.0)

    # Plot the resulting vector from the starting point
    arrows2d!(ax, [start_point[1]], [start_point[2]], [v_result[1]], [v_result[2]], 
            color=wong_colors[5], shaftwidth=4, tipwidth=15, tiplength=15, lengthscale=1.0)

    # Add vector addition visualization (tip-to-tail method)
    tip1 = start_point + v1
    tip2 = tip1 + v2
    lines!(ax, [tip1[1], tip2[1]], [tip1[2], tip2[2]], 
          linestyle=:dash, color=wong_colors[2], alpha=0.7, linewidth=2)
    lines!(ax, [tip2[1], tip2[1]+v3[1]], [tip2[2], tip2[2]+v3[2]], 
          linestyle=:dash, color=wong_colors[3], alpha=0.7, linewidth=2)

    # No text annotations inside the plot - they will be in the legend
end

# Define base vectors and starting point
start_point = [0.0, 3.0]
v1s = [-0.8, 0.5]/0.5    # First vector (Wong blue)
v2s = [0.5, +0.5]/0.8   # Second vector (Wong vermillion)
v3s = [-0.6, -1]/(-0.7)   # Third vector (Wong bluish green)

v1p = [0.5, 0.5]/0.5
v2p = [-0.8, +0.5]/0.6
v3p = [-0.5, -1]/-0.7

v1q = [-0.8, 0.4]/0.5
v2q = [-0.8, +0.5]/(-0.6)
v3q = [-0.3, -1]/(0.7)

# Create 1x3 grid figure with space for legend
fig = Figure(size = (600, 350))  # Wider figure for 3 subplots + legend

# Create three different scenarios with different scaling factors
ax1 = Axis(fig[1, 1])
create_vector_plot!(ax1, v1s, v2s, v3s, [0.5, 0.8, -0.7], start_point, "OP 1")

ax2 = Axis(fig[1, 2]) 
create_vector_plot!(ax2, v1p, v2p, v3p, [0.5, 0.6, -0.7], start_point, "OP 2")

ax3 = Axis(fig[1, 3])
create_vector_plot!(ax3, v1q, v2q, v3q, [0.5, -0.6, 0.7], start_point, "N-th OP")

# Create legend in a separate area (right side of the figure)
legend_elements = [
    LineElement(color = wong_colors[1], linestyle = :solid, linewidth = 3),
    LineElement(color = wong_colors[2], linestyle = :solid, linewidth = 3),
    LineElement(color = wong_colors[3], linestyle = :solid, linewidth = 3),
    LineElement(color = wong_colors[1], linestyle = :solid, linewidth = 3, alpha = 0.4),
    LineElement(color = wong_colors[2], linestyle = :solid, linewidth = 3, alpha = 0.4),
    LineElement(color = wong_colors[3], linestyle = :solid, linewidth = 3, alpha = 0.4),
    LineElement(color = wong_colors[5], linestyle = :solid, linewidth = 4),
    #LineElement(color = :gray, linestyle = :dash, linewidth = 2)
]

legend_labels = [
    L"a_1S_{\Delta u_1}",
    L"a_2S_{\Delta u_2}", 
    L"a_3S_{\Delta u_3}",
    L"S_{\Delta u_1}",
    L"S_{\Delta u_2}",
    L"S_{\Delta u_3}",
    L"S_{\Delta u}",
]

Legend(fig[2, 1:end], legend_elements, legend_labels, framevisible = false, orientation = :horizontal, labelsize = 28, nbanks=2)

#leg = Legend(fig, line_handles, line_labels, framevisible = false, halign = :center, orientation = :vertical, nbanks = 1, labelsize = 18)

# Display and save the plot
display(fig)

# Save the plot for your paper
save("figures/vector_addition_grid_illustration.svg", fig)
save("figures/vector_input.png", fig)


