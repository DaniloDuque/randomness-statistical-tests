using Distributions

function poker_test_uniform(sample::Vector{Float64}, α::Float64=0.05):Bool
    
    # Initialize observed frequencies
    fₒ = zeros(Int, 7)
    
    # Step 1: Classify each number
    for num in sample
        # Extract first 5 digits after decimal point
        str_num = string(num)
        if occursin(".", str_num)
            decimal_part = split(str_num, ".")[2]
            # Take first 5 digits (pad with zeros if necessary)
            digits = collect(decimal_part[1:min(5, length(decimal_part))])
            
            # Pad with zeros if less than 5 digits
            while length(digits) < 5
                push!(digits, '0')
            end
            
            # Count frequency of each digit
            digit_counts = Dict{Char, Int}()
            for d in digits
                digit_counts[d] = get(digit_counts, d, 0) + 1
            end
            
            # Get the counts and sort them
            counts = sort(collect(values(digit_counts)), rev=true)
            
            # Classify based on pattern
            if counts == [5]
                fₒ[7] += 1  # Five of a Kind
            elseif counts == [4, 1]
                fₒ[6] += 1  # Four of a Kind
            elseif counts == [3, 2]
                fₒ[5] += 1  # Full House
            elseif counts == [3, 1, 1]
                fₒ[4] += 1  # Three of a Kind
            elseif counts == [2, 2, 1]
                fₒ[3] += 1  # Two Pairs
            elseif counts == [2, 1, 1, 1]
                fₒ[2] += 1  # One Pair
            elseif counts == [1, 1, 1, 1, 1]
                fₒ[1] += 1  # All Different
            end
        end
    end
    
    n = length(sample)
    
    # Step 2: Calculate expected probabilities
    # Based on combinatorial analysis with 10 possible digits (0-9)
    pₑ = [
        0.3024,   # P(all different) = (10×9×8×7×6)/(10^5) × C(5,0)
        0.5040,   # P(one pair) = (10×1×9×8×7)/(10^5) × C(5,2)
        0.1080,   # P(two pairs) = (1/2)×(10×1×9×1×8)/(10^5) × C(5,2)×C(3,2)
        0.0720,   # P(three of a kind) = (10×1×1×9×8)/(10^5) × C(5,3)
        0.0090,   # P(full house) = (10×1×1×9×1)/(10^5) × C(5,3)×C(2,2)
        0.0045,   # P(four of a kind) = (10×1×1×1×9)/(10^5) × C(5,4)
        0.0001    # P(five of a kind) = (10×1×1×1×1)/(10^5) × C(5,5)
    ]
    
    # Step 3: Calculate expected frequencies
    fₑ = pₑ * n
    
    # Step 4: Compute χ² statistic
    χ²₀ = sum(((fₒ[i] - fₑ[i])^2) / fₑ[i] for i in 1:length(fₒ))
    
    # Step 5: Determine critical value
    df = 6  # k - 1 = 7 - 1
    χ²_critical = quantile(Chisq(df), 1 - α)
    
    # Step 6: Return decision
    return χ²₀ <= χ²_critical
end