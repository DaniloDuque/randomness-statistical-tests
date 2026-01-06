function read_sample()
    n = parse(Int, readline())
    
    numbers = Float64[]
    for i in 1:n
        push!(numbers, parse(Float64, readline()))
    end
    
    return numbers
end
