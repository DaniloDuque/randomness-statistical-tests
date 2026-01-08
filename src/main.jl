include("utils/sample_reader.jl")
include("utils/distribution_utils.jl")
include("proofs/mean_test.jl")
include("proofs/variance_test.jl")
include("proofs/runs_test.jl")
include("proofs/digit_gap_test.jl")
include("proofs/number_gap_test.jl")
include("proofs/poker_test.jl")
include("proofs/series_test.jl")

xmin, xmax, numbers = read_sample()

mean_test_uniform(numbers)

variance_test_uniform(numbers)

runs_test_uniform(numbers)

digit_gap_test_uniform(numbers)

inf, sup = 0.3, 0.7
number_gap_test(numbers, inf, sup)

poker_test_uniform(numbers)

series_test(numbers)

