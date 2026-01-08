# distribution_utils.jl
using Statistics

function normalize_to_01(numbers, min, max)
    if max == 1
        return numbers
    end
    @assert max > 0
    return [(x - min)/(max - min) for x in numbers]
end

function gauss(n::Int)::Int
    return n*(n+1)/2
end

function get_theoretical_mean(min, max)
    if max == 1
        return 0.5
    end
    @assert min > 0
    x̄ = (gauss(max) - gauss(min-1)) / (max - min + 1)
    return x̄ / (max - 1)
end

"""
get_theoretical_variance(min_val, max_val, is_continuous=false)

Get theoretical variance for uniform distributions.

# Arguments
- `min_val`: Minimum value
- `max_val`: Maximum value
- `is_continuous`: true for continuous, false for discrete
"""
function get_theoretical_variance(max_val, is_continuous=false, min_val=1)
    if is_continuous
        # For continuous [0, max_val)
        # Actually for [0,1), max_val should be 1
        return max_val^2 / 12  # (max-0)²/12
    else
        # For discrete {min_val, ..., max_val}
        # Default min_val = 1
        n = max_val - min_val + 1
        return ((n^2 - 1)/12) / ((max_val - min_val)^2)
    end
end
