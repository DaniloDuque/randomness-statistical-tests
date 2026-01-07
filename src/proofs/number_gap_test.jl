using Statistics, Distributions, Printf

"""
    number_gap_test(numbers, inf, sup; alpha=0.05, max_gap_cutoff=20)::NamedTuple

Perform the number gap test for a given interval [inf, sup].

# Arguments
- `numbers`: Vector of Float64 values in [0,1]
- `inf`: Lower bound of interval (0 ≤ inf ≤ 1)
- `sup`: Upper bound of interval (inf ≤ sup ≤ 1)
- `alpha`: Significance level (default 0.05)
- `max_gap_cutoff`: Maximum gap size to consider individually (gaps ≥ this are grouped)

# Returns
- Named tuple with test results and statistics
"""
function number_gap_test(numbers::Vector{Float64}, inf::Float64, sup::Float64; 
                        alpha::Float64=0.05, max_gap_cutoff::Int=3)::NamedTuple
    
    # Validate interval
    @assert 0 ≤ inf ≤ sup ≤ 1 "Interval [inf, sup] must be within [0,1]"
    
    n = length(numbers)
    t = sup - inf  # Probability of falling in interval
    
    println("="^60)
    println("PRUEBA DE HUECOS CON NÚMEROS")
    println("="^60)
    println("Intervalo seleccionado: [$inf, $sup]")
    println("Probabilidad t = sup - inf = $t")
    println("Tamaño de muestra: $n números")
    println()
    
    # Step 1: Calculate gaps
    gaps = Int[]
    in_gap = false
    current_gap = 0
    
    for x in numbers
        if inf ≤ x ≤ sup
            # Number is inside interval
            if in_gap
                # End of gap
                push!(gaps, current_gap)
                current_gap = 0
                in_gap = false
            else
                # Consecutive numbers inside interval → gap of size 0
                push!(gaps, 0)
            end
        else
            # Number is outside interval
            if !in_gap
                in_gap = true
            end
            current_gap += 1
        end
    end
    
    # Don't count trailing gap (if last number started a gap but didn't end it)
    total_gaps = length(gaps)
    
    println("Huecos encontrados: $total_gaps")
    println()
    
    # Step 2: Calculate observed frequencies
    # Categories: gap = 0, 1, 2, ..., max_gap_cutoff-1, gap ≥ max_gap_cutoff
    observed = zeros(Int, max_gap_cutoff + 1)  # +1 for the "≥max_gap_cutoff" category
    
    for gap in gaps
        if gap < max_gap_cutoff
            observed[gap + 1] += 1  # +1 because gap=0 goes to index 1
        else
            observed[end] += 1  # Last category: gap ≥ max_gap_cutoff
        end
    end
    
    # Step 3: Calculate theoretical probabilities (geometric distribution)
    # P(gap = x) = t * (1 - t)^x
    theoretical_probs = Float64[]
    
    for x in 0:(max_gap_cutoff-1)
        prob = t * (1 - t)^x
        push!(theoretical_probs, prob)
    end
    
    # Last category: P(gap ≥ max_gap_cutoff) = (1 - t)^max_gap_cutoff
    prob_last = (1 - t)^max_gap_cutoff
    push!(theoretical_probs, prob_last)
    
    # Expected frequencies
    expected = theoretical_probs .* total_gaps
    
    # Step 4: Display frequency table
    println("TABLA DE FRECUENCIAS:")
    println("-"^65)
    println(" Hueco |  fo   |   pe    |   fe   | fo-fe  | (fo-fe)² | (fo-fe)²/fe")
    println("-"^65)
    
    chi2_stat = 0.0
    for i in 1:length(observed)
        gap_label = i ≤ max_gap_cutoff ? string(i-1) : "≥$max_gap_cutoff"
        fo = observed[i]
        pe = theoretical_probs[i]
        fe = expected[i]
        diff = fo - fe
        diff_sq = diff^2
        chi2_contrib = fe > 0 ? diff_sq / fe : 0.0
        
        chi2_stat += chi2_contrib
        
        @printf(" %5s | %5d | %7.4f | %7.2f | %7.2f | %8.4f | %10.4f\n",
                gap_label, fo, pe, fe, diff, diff_sq, chi2_contrib)
    end
    println("-"^65)
    @printf(" Total | %5d | %7.4f | %7.2f |        |          | %10.4f\n",
            sum(observed), sum(theoretical_probs), sum(expected), chi2_stat)
    println()
    
    # Step 5: Chi-square test
    df = length(observed) - 1  # degrees of freedom
    critical_value = quantile(Chisq(df), 1 - alpha)
    p_value = 1 - cdf(Chisq(df), chi2_stat)
    
    # Step 6: Decision
    passed = chi2_stat < critical_value
    
    println("PRUEBA CHI-CUADRADO:")
    println("-"^40)
    println("χ² observado: $(round(chi2_stat, digits=4))")
    println("χ² crítico (α=$alpha, df=$df): $(round(critical_value, digits=4))")
    println("Valor p: $(round(p_value, digits=6))")
    println()
    
    if passed
        println("✓ DECISIÓN: Se ACEPTA H₀")
        println("  Los números siguen distribución uniforme")
    else
        println("✗ DECISIÓN: Se RECHAZA H₀")
        println("  Los números NO siguen distribución uniforme")
    end
    println("="^60)
    
    # Return detailed results
    return (
        passed = passed,
        chi2_statistic = chi2_stat,
        critical_value = critical_value,
        p_value = p_value,
        degrees_of_freedom = df,
        interval = (inf, sup),
        probability_t = t,
        total_gaps = total_gaps,
        observed_frequencies = observed,
        expected_frequencies = expected,
        theoretical_probabilities = theoretical_probs,
        gaps_data = gaps
    )
end

"""
    number_gap_test_auto_interval(numbers; alpha=0.05)::Vector{NamedTuple}

Automatically test with several standard intervals.
"""
function number_gap_test_auto_interval(numbers::Vector{Float64}; alpha::Float64=0.05)
    # Define some standard intervals
    intervals = [
        (0.3, 0.7),  # Standard: probability 0.4
        (0.2, 0.8),  # Probability 0.6
        (0.4, 0.6),  # Probability 0.2 (narrow)
        (0.0, 0.5),  # First half
        (0.5, 1.0),  # Second half
    ]
    
    results = []
    
    for (inf, sup) in intervals
        println("\n" * "="^60)
        println("Probando intervalo: [$inf, $sup]")
        println("="^60)
        
        result = number_gap_test(numbers, inf, sup, alpha=alpha)
        push!(results, result)
        
        # Add some spacing between tests
        println()
    end
    
    # Summary
    println("\n" * "="^60)
    println("RESUMEN DE TODAS LAS PRUEBAS")
    println("="^60)
    
    passed_count = sum([r.passed for r in results])
    total_tests = length(results)
    
    for (i, (inf, sup)) in enumerate(intervals)
        result = results[i]
        symbol = result.passed ? "✓" : "✗"
        println("$symbol [$inf, $sup]: χ²=$(round(result.chi2_statistic, digits=3)), p=$(round(result.p_value, digits=4))")
    end
    
    println("\nPruebas que pasan: $passed_count/$total_tests")
    
    if passed_count == total_tests
        println("✓ TODAS las pruebas indican distribución uniforme")
    elseif passed_count >= total_tests ÷ 2
        println("～ La mayoría de pruebas indican distribución uniforme")
    else
        println("✗ La mayoría de pruebas NO indican distribución uniforme")
    end
    
    return results
end

"""
    analyze_gap_distribution(gaps, inf, sup)

Calculate statistics about the gaps.
"""
function analyze_gap_distribution(gaps::Vector{Int}, inf::Float64, sup::Float64)
    t = sup - inf
    n_gaps = length(gaps)
    
    if n_gaps == 0
        return (mean_gap = NaN, std_gap = NaN, max_gap = NaN, min_gap = NaN)
    end
    
    mean_gap = mean(gaps)
    std_gap = std(gaps)
    max_gap = maximum(gaps)
    min_gap = minimum(gaps)
    
    # Theoretical mean for geometric distribution: (1-t)/t
    theoretical_mean = (1 - t) / t
    
    return (
        observed_mean = mean_gap,
        theoretical_mean = theoretical_mean,
        std_dev = std_gap,
        max_gap = max_gap,
        min_gap = min_gap,
        total_gaps = n_gaps
    )
end