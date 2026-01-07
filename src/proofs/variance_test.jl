using Statistics, Distributions

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
    sigma2_theoretical = 1 / 12  # ≈ 0.0833333
    
    # Sample variance
    s2 = var(x)
    
    # Chi-squared test statistic
    chi2_stat = (n - 1) * s2 / sigma2_theoretical
    
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
    
    # Return true if we fail to reject H0
    return chi2_lower <= chi2_stat <= chi2_upper
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