function read_sample()
    line = readline()
    if isempty(strip(line))
        error("First line is empty")
    end
    n = parse(Int, strip(line))
    
    numbers = Float64[]
    for i in 1:n
        line = readline()
        if isempty(strip(line))
            error("Unexpected empty line at position $i")
        end
        push!(numbers, parse(Float64, strip(line)))
    end
    
    return numbers
end
