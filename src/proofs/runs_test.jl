using Statistics
using Distributions
using Plots
using Printf

# ------------------------------------------------------------
# Runs test plot (saved to file)
# ------------------------------------------------------------
function plot_runs_ztest(z₀, z_critical; filename = "runs_test_ztest.png")
    z_vals = range(-4, 4, 1000)
    pdf_vals = pdf.(Normal(), z_vals)

    p = plot(
        z_vals,
        pdf_vals,
        label = "N(0,1)",
        title = "Runs Test (Z-test)",
        xlabel = "z",
        ylabel = "Density",
        linewidth = 2
    )

    vline!(p, [-z_critical, z_critical],
           label = ["-zₐ/₂" "zₐ/₂"],
           linestyle = :dash)

    vline!(p, [z₀],
           label = "z₀",
           linewidth = 2)

    savefig(p, filename)
end

# ------------------------------------------------------------
# Runs test (uniformity)
# ------------------------------------------------------------
function runs_test_uniform(sample::Vector{Float64};
                           α::Float64 = 0.05,
                           prefix::String = "runs_test")

    n = length(sample)

    # + if xᵢ₋₁ ≤ xᵢ, − otherwise
    symbols = [sample[i-1] <= sample[i] ? '+' : '-' for i in 2:n]

    # Number of runs
    h = sum(symbols[i] != symbols[i-1] for i in 2:length(symbols)) + 1

    # Expected value and variance
    E_h = (2n - 1) / 3
    σ_h = sqrt((16n - 29) / 90)

    # Test statistic
    z₀ = (h - E_h) / σ_h
    z_critical = quantile(Normal(), 1 - α/2)
    p_value = 2 * (1 - cdf(Normal(), abs(z₀)))

    # Save plot
    plot_runs_ztest(z₀, z_critical;
        filename = "$(prefix)_ztest.png")

    passed = abs(z₀) ≤ z_critical

    # --------------------------------------------------------
    # Terminal table
    # --------------------------------------------------------
    println()
    println("┌──────────────────────────────────────────────────────────┐")
    println("│        Runs Test — Uniform                               │")
    println("├──────────────────────────────┬───────────────────────────┤")
    println(rpad("│ Significance level α", 31), "│ ", lpad(string(α), 25), " │")
    println(rpad("│ Sample size n", 31), "│ ", lpad(string(n), 25), " │")
    println(rpad("│ Number of runs h", 31), "│ ", lpad(string(h), 25), " │")
    println(rpad("│ E[h]", 31), "│ ", lpad(@sprintf("%.6f", E_h), 25), " │")
    println(rpad("│ σₕ", 31), "│ ", lpad(@sprintf("%.6f", σ_h), 25), " │")
    println(rpad("│ Z statistic z₀", 31), "│ ", lpad(@sprintf("%.6f", z₀), 25), " │")
    println(rpad("│ p-value", 31), "│ ", lpad(@sprintf("%.6f", p_value), 25), " │")
    println("├──────────────────────────────┼───────────────────────────┤")
    println(rpad("│ Decision", 31), "│ ",
            lpad(passed ? "ACCEPT H₀" : "REJECT H₀", 25), " │")
    println("├──────────────────────────────┼───────────────────────────┤")
    println(rpad("│ Saved plot", 31), "│ ",
            lpad("$(prefix)_ztest.png", 25), " │")
    println("└──────────────────────────────┴───────────────────────────┘")
    println()

    return nothing
end
