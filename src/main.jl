include("sample_reader.jl")
include("proofs/mean_test.jl")

numbers = read_sample()
is_uniform = mean_test_uniform(numbers)
println("Sample is uniform: $is_uniform")
