function read_sample()
    n = parse(Int, strip(readline()))
    
    numbers = Float64[]
    for i in 1:n
        push!(numbers, parse(Float64, strip(readline())))
    end
    
    return numbers
end
