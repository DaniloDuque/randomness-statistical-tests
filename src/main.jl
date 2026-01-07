include("sample_reader.jl")
include("proofs/mean_test.jl")
include("proofs/variance_test.jl")
include("proofs/runs_test.jl")
include("proofs/digit_gap_test.jl")
include("proofs/number_gap_test.jl")
include("proofs/poker_test.jl")
include("proofs/series_test.jl")
include("graphics/histogram.jl")

numbers = read_sample()
is_uniform = mean_test_uniform(numbers)
is_uniform2 = variance_test_uniform(numbers)
is_uniform3 = runs_test_uniform(numbers)
is_uniform4 = digit_gap_test_uniform(numbers)
println("Sample behaves uniform (mean): $is_uniform \n\n\n")
println("Sample behaves uniform (variance): $is_uniform2\n\n\n")
println("Sample behaves uniform (runs): $is_uniform3 \n\n\n")
println("Sample behaves uniform (digit gap): $is_uniform4 \n\n\n")


# Number gap test (with standard interval [0.3, 0.7])

# Use standard interval from the example
inf, sup = 0.3, 0.7
gap_results = number_gap_test(numbers, inf, sup)
ng_passed = gap_results.passed
println("Sample behaves uniform (number gap) : $ng_passed \n\n\n")

is_uniform5 = poker_test_uniform(numbers)
println("Sample behaves uniform (poker): $is_uniform5 \n\n\n")

# Series test
println("4. PRUEBA DE SERIES:")
println("-"^40)
series_results = series_test(numbers, 5)  # Default 5×5 grid
s_passed = series_results.passed
println("Sample behaves uniform (series) : $s_passed \n\n\n")
