using QuESTMbqcBqpVerification
using Test


tolerance=1e-10
num_iterations=1<<2

include("../test/QuEST_test_functions.jl")
include("../test/test_functions.jl")

include("../test/QuEST_testsets.jl")
include("../test/testsets.jl")