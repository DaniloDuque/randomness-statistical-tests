using Distributions

function digit_gap_test_uniform(sample::Vector{Float64}, α::Float64=0.05, max_gap::Int=6)
    # Step 1: Extract digits after decimal point as characters
    digits = Char[]
    for num in sample
        str_num = string(num)
        if occursin(".", str_num)
            decimal_part = split(str_num, ".")[2]
            append!(digits, collect(decimal_part))
        end
    end
    
    # Step 2 & 3: Count gaps for each digit (0-9)
    gap_counts = Dict{Char, Vector{Int}}()
    
    for target_digit in '0':'9'
        gaps = Int[]
        last_position = -1
        
        # Find gaps in a single pass
        for (i, d) in enumerate(digits)
            if d == target_digit
                if last_position != -1
                    gap_size = i - last_position - 1
                    push!(gaps, gap_size)
                end
                last_position = i
            end
        end
        
        gap_counts[target_digit] = gaps
    end
    
    # Step 4: Build frequency table
    # Count total gaps across all digits
    total_gaps = sum(length(gap_counts[d]) for d in '0':'9')
    
    # Initialize observed frequencies
    fₒ = zeros(Int, max_gap + 2)  # 0, 1, 2, ..., max_gap, ≥(max_gap+1)
    
    for digit in '0':'9'
        for gap in gap_counts[digit]
            if gap <= max_gap
                fₒ[gap + 1] += 1  # +1 because arrays are 1-indexed
            else
                fₒ[max_gap + 2] += 1  # Last category is ≥(max_gap+1)
            end
        end
    end
    
    # Step 5: Calculate expected probabilities
    # P(x) = 0.1 × 0.9ˣ
    pₑ = zeros(Float64, max_gap + 2)
    
    for i in 0:max_gap
        pₑ[i + 1] = 0.1 * (0.9^i)
    end
    
    # P(x ≥ n) = 0.9ⁿ
    pₑ[max_gap + 2] = 0.9^(max_gap + 1)
    
    # Step 6: Calculate expected frequencies
    fₑ = pₑ * total_gaps
    
    # Step 7: Compute χ² statistic
    χ²₀ = sum(((fₒ[i] - fₑ[i])^2) / fₑ[i] for i in 1:length(fₒ))
    
    # Step 8: Determine critical value
    # Degrees of freedom = k - 1
    df = length(fₒ) - 1
    χ²_critical = quantile(Chisq(df), 1 - α)
    
    # Step 9: Make decision
    return χ²₀ <= χ²_critical
end