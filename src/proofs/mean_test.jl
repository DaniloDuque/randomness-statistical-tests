using Statistics
using Plots
using Distributions
using Printf

# ------------------------------------------------------------
# Z-test plot
# ------------------------------------------------------------
function plot_mean_ztest(Z, z_critical; filename = "mean_ztest.png")
    z_vals = range(-4, 4, 1000)
    pdf_vals = pdf.(Normal(), z_vals)

    p = plot(
        z_vals,
        pdf_vals,
        label = "N(0,1)",
        title = "Mean Test (Z-test)",
        xlabel = "z",
        ylabel = "Density",
        linewidth = 2
    )

    vline!(p, [-z_critical, z_critical],
           label = ["-zₐ/₂" "zₐ/₂"],
           linestyle = :dash)

    vline!(p, [Z],
           label = "z₀",
           linewidth = 2)

    savefig(p, filename)
end

# ------------------------------------------------------------
# Mean test
# ------------------------------------------------------------
function mean_test_uniform(x; α = 0.05, prefix = "mean_test")
    n = length(x)

    μ = 0.5
    σ² = 1 / 12
    σ = sqrt(σ²)

    x̄ = mean(x)
    Z = (x̄ - μ) / (σ / sqrt(n))
    z_critical = quantile(Normal(), 1 - α/2)

    plot_mean_ztest(Z, z_critical; filename = "$(prefix)_ztest.png")

    passed = abs(Z) < z_critical

    println()
    println("┌──────────────────────────────────────────────────────────┐")
    println("│        Mean Test — Uniform.                              │")
    println("├──────────────────────────────┬───────────────────────────┤")
    println(rpad("│ Significance level α", 31), "│ ", lpad(string(α), 25), " │")
    println(rpad("│ Sample size n", 31), "│ ", lpad(string(n), 25), " │")
    println(rpad("│ Sample mean x̄", 31), "│ ", lpad(@sprintf("%.6f", x̄), 25), " │")
    println(rpad("│ Z statistic", 31), "│ ", lpad(@sprintf("%.6f", Z), 25), " │")
    println("├──────────────────────────────┼───────────────────────────┤")
    println(rpad("│ Decision", 31), "│ ",
            lpad(passed ? "ACCEPT H₀" : "REJECT H₀", 25), " │")
    println("├──────────────────────────────┼───────────────────────────┤")
    println(rpad("│ Saved plot", 31), "│ ",
            lpad("$(prefix)_ztest.png", 25), " │")
    println("└──────────────────────────────┴───────────────────────────┘")
    println()


end
