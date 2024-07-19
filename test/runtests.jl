using VeriQuEST
using Test
using LinearAlgebra
using Chain
using Graphs
using Revise
using MetaGraphs
using Random # Needed for shuffle function
using RandomMatrices
using Combinatorics # For permutations
using Printf
using StatsBase


tolerance=1e-10
num_iterations=1<<2


include("../test/test_functions.jl")
include("../test/testsets.jl")