using Statistics

function mean_test_uniform(x; alpha=0.05)::Bool
    n = length(x)

    mu = 0.5
    sigma2 = 1 / 12

    x̄ = mean(x)
    Z = (x̄ - mu) / sqrt(sigma2 / n)

    z_critical = 1.96

    return abs(Z) < z_critical
end

