using Plots

function plot_histogram_uniform(numbers; bins=20)
    # Create histogram
    histogram(numbers, 
        bins=bins,
        normalize=:pdf,  # Normalize to show probability density
        alpha=0.6,
        label="Sample",
        xlabel="Value",
        ylabel="Density",
        title="Histogram of Uniform(0,1) Sample (n=$(length(numbers)))"
    )
    
    # Overlay theoretical uniform PDF
    x_range = range(0, 1, length=100)
    theoretical_pdf = fill(1.0, 100)  # PDF = 1 for Uniform(0,1)
    plot!(x_range, theoretical_pdf, 
        linewidth=2, 
        linecolor=:red, 
        label="Theoretical PDF"
    )
    
    # Add mean and variance information
    mean_val = mean(numbers)
    var_val = var(numbers)
    theoretical_var = 1/12
    
    annotate!(0.7, 0.9, text("Sample mean: $(round(mean_val, digits=4))", 8))
    annotate!(0.7, 0.85, text("Sample var: $(round(var_val, digits=4))", 8))
    annotate!(0.7, 0.8, text("Theoretical var: $(round(theoretical_var, digits=4))", 8))
    
    return current()
end