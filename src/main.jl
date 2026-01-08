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

# variance_test_uniform(numbers)
# inf, sup = 0.2, 0.7
# number_gap_test(numbers, inf, sup)
series_test(numbers)

# mean_test_uniform(numbers)
# runs_test_uniform(numbers)
# digit_gap_test_uniform(numbers)
# poker_test_uniform(numbers)
