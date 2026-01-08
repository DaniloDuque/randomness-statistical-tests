include("distribution_utils.jl")

function read_sample()
    n = parse(Int, readline())
    line = readline()
    min, max = parse.(Int, split(line))
    
    numbers = Float64[]
    for i in 1:n
        push!(numbers, parse(Float64, readline()))
    end
    
    # return min, max, numbers
    return min, max, normalize_to_01(numbers, min, max)
end