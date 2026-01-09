using Statistics, Distributions



"""
    plot_variance_test(chi2_stat, df; alpha=0.05, filename="variance_test.png")

Simple plot for chi-squared variance test.
"""
function plot_variance_test(chi2_stat, df; alpha=0.05, filename="variance_test.png")
    dist = Chisq(df)
    lower = quantile(dist, alpha/2)
    upper = quantile(dist, 1 - alpha/2)
    
    # Calculate reasonable x-axis range
    # Chi-squared has mean = df, variance = 2df
    mean = df
    std_dev = sqrt(2 * df)
    
    # Show ±4 standard deviations around test statistic or mean
    if df > 100
        # For large df, center on test statistic
        center = chi2_stat
        x_min = max(0, center - 4*std_dev)
        x_max = center + 4*std_dev
    else
        # For small df, center on distribution
        x_min = 0
        x_max = max(upper, chi2_stat) * 1.5
    end
    
    # Ensure critical values are visible
    x_min = min(x_min, lower * 0.9)
    x_max = max(x_max, upper * 1.1)
    
    x_vals = range(x_min, x_max, length=500)
    y_vals = pdf.(dist, x_vals)
    
    p = plot(x_vals, y_vals,
             label="χ²(df=$df)",
             title="Variance Test (n=$(df+1))",
             xlabel="χ²",
             ylabel="Density",
             linewidth=2)
    
    vline!([lower, upper],
           label=["χ²(α/2)" "χ²(1-α/2)"],
           linestyle=:dash,
           color=:red)
    
    vline!([chi2_stat],
           label="χ²₀ = $(round(chi2_stat, digits=3))",
           linewidth=3,
           color=:green)
    
    savefig(p, filename)
    # println("Plot saved: $filename")
    return p
end

"""

Test if the variance of sample `x` matches the theoretical variance of a Uniform(0,1) distribution.

# Arguments
- `x`: Array of Float64 values assumed to be from Uniform(0,1)
- `alpha`: Significance level (default 0.05)

# Returns
- `true` if we fail to reject the null hypothesis (variance matches theoretical)
- `false` if we reject the null hypothesis (variance differs significantly)

# Theory
For Uniform(0,1):
- Theoretical variance: σ² = 1/12 ≈ 0.0833333
- Test statistic: χ² = (n-1) * s² / σ²
  where s² is sample variance
- Follows Chi-squared distribution with (n-1) degrees of freedom
"""
function variance_test_uniform(x; alpha=0.05)::Bool
    n = length(x)
    
    # Theoretical variance for Uniform(0,1)
    sigma2 = 1 / 12  # ≈ 0.0833333
    
    # Sample variance
    s2 = var(x)
    
    # Chi-squared test statistic
    chi2 = (n - 1) * s2 / sigma2    

    # Degrees of freedom
    df = n - 1
    
    # Critical values from Chi-squared distribution
    # Two-tailed test: reject if variance is too small OR too large
    chi2_lower = quantile(Chisq(df), alpha/2)
    chi2_upper = quantile(Chisq(df), 1 - alpha/2)
    """
    For a distribution and a probability p (between 0 and 1):

    quantile(dist, p) returns the value x where P(X ≤ x) = p

    In other words: p * 100% of the probability mass is to the left of x
    """

    # Confidence interval
    L_inf = chi2_lower * sigma2 / (n - 1)
    L_sup = chi2_upper * sigma2 / (n - 1)

    passed = chi2_lower <= chi2 <= chi2_upper

    println("─"^80)
    println("="^60)
    println("PRUEBA DE VARIANZA")
    println("="^60)
    println("n = $n, x̄ = $(round(mean(x), digits=6)), s² = $(round(s2, digits=6))")
    println("σ² teórico = 1/12 = $(round(sigma2, digits=6))")
    println()
    println("χ²₀ = $(round(chi2, digits=4)), df = $df")
    println("χ²(α/2=$alpha/2, $df) = $(round(chi2_lower, digits=4))")
    println("χ²(1-α/2=$(1-alpha/2), $df) = $(round(chi2_upper, digits=4))")
    println("Intervalo aceptación: [$(round(chi2_lower, digits=4)), $(round(chi2_upper, digits=4))]")
    println()
    println("IC 95% para σ²: [$(round(L_inf, digits=6)), $(round(L_sup, digits=6))]")
    println("s² = $(round(s2, digits=6)) $(s2 >= L_inf && s2 <= L_sup ? "∈" : "∉") IC")
    println()
    println("Resultado: $(passed ? "ACEPTA H₀" : "RECHAZA H₀")")
    println("Conclusión: Varianza $(passed ? "ES" : "NO ES") consistente con Uniform(0,1)")

    println("="^60)
    try
        plot_variance_test(chi2, df, alpha=alpha, filename="variance_test.png")
    catch e
        println("\nNote: Plot failed. Install Plots.jl: using Pkg; Pkg.add(\"Plots\")")
    end
    println("─"^80)
    
    # Return true if we fail to reject H0
    return passed
end

"""
    variance_test_uniform_pvalue(x)::Float64

Calculate the p-value for the variance test.

# Returns
- Two-tailed p-value for the variance test
"""
function variance_test_uniform_pvalue(x)::Float64
    n = length(x)
    sigma2_theoretical = 1 / 12
    s2 = var(x)
    chi2_stat = (n - 1) * s2 / sigma2_theoretical
    df = n - 1
    
    # Two-tailed p-value
    p_lower = cdf(Chisq(df), chi2_stat)
    p_upper = 1 - p_lower
    p_value = 2 * min(p_lower, p_upper)

    
    return p_value
end

"""
    variance_test_uniform_details(x; alpha=0.05)::NamedTuple

Return detailed results of the variance test.

# Returns
Named tuple with:
- `passed`: Bool test result
- `sample_variance`: Float64 sample variance
- `theoretical_variance`: Float64 theoretical variance (1/12)
- `chi2_stat`: Float64 test statistic
- `critical_lower`: Float64 lower critical value
- `critical_upper`: Float64 upper critical value  
- `p_value`: Float64 p-value
"""
function variance_test_uniform_details(x; alpha=0.05)
    n = length(x)
    sigma2_theoretical = 1 / 12
    s2 = var(x)
    chi2_stat = (n - 1) * s2 / sigma2_theoretical
    df = n - 1
    
    chi2_lower = quantile(Chisq(df), alpha/2)
    chi2_upper = quantile(Chisq(df), 1 - alpha/2)
    passed = chi2_lower <= chi2_stat <= chi2_upper
    
    p_lower = cdf(Chisq(df), chi2_stat)
    p_upper = 1 - p_lower
    p_value = 2 * min(p_lower, p_upper)

    
    return (
        passed = passed,
        sample_variance = s2,
        theoretical_variance = sigma2_theoretical,
        chi2_stat = chi2_stat,
        critical_lower = chi2_lower,
        critical_upper = chi2_upper,
        p_value = p_value,
        n = n,
        degrees_of_freedom = df
    )
end