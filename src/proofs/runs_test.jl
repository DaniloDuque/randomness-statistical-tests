using Statistics, Distributions


function runs_test_uniform(sample::Vector{Float64}, α::Float64=0.05)
    n = length(sample)
    
    # Step 1: Classify each number with respect to the previous one
    # f(nᵢ, nᵢ₊₁) = { + if nᵢ ≤ nᵢ₊₁
    #              { - if nᵢ > nᵢ₊₁
    symbols = [sample[i-1] <= sample[i] ? '+' : '-' for i in 2:n]
    
    # Step 2: Count the number of runs (h)
    # Each time the symbol changes, we add 1 to the run count
    h = 1
    for i in 2:length(symbols)
        if symbols[i] != symbols[i-1]
            h += 1
        end
    end
    
    E_h = (2n - 1) / 3
    σ_h = sqrt((16n - 29) / 90)
    z₀ = (h - E_h) / σ_h
    
    # Step 5: Calculate critical value z_{α/2}
    z_critical = quantile(Normal(0, 1), 1 - α/2)
    
    # Step 6: Calculate p-value (two-tailed test)
    p_value = 2 * (1 - cdf(Normal(0, 1), abs(z₀)))
    
    # Step 7: Decision
    # Accept H₀ if |z₀| ≤ z_{α/2}
    result = abs(z₀) <= z_critical
end