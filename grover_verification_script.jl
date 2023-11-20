##################################################################
# Filename  : grovers_verification_example.jl
# Author    : Jonathan Miller
# Date      : 2023-11-03
# Aim       : The pluto notebook is an expanded version
#           : to show the Grovers algorithm works on the verification
#           : simulator. This script is a trimmed down version.
##################################################################


using Pkg
Pkg.activate(".")
using Test
using StatsBase
using Graphs
using CairoMakie

include("src/QuESTMbqcBqpVerification.jl")
using .QuESTMbqcBqpVerification 

# Choose backend and round counts
state_type = DensityMatrix()
total_rounds,computation_rounds = 100,50

# Grover graph
num_vertices = 8
graph = Graph(num_vertices)
add_edge!(graph,1,2)
add_edge!(graph,2,3)
add_edge!(graph,3,6)
add_edge!(graph,6,7)
add_edge!(graph,1,4)
add_edge!(graph,4,5)
add_edge!(graph,5,8)
add_edge!(graph,7,8)



input = (indices = (),values = ())
output = (7,8)
#input_indices = () # a tuple of indices 
#input_values = () # a tuple of input values
#output_indices = (7,8) # Grovers: 7,8



# Julia is indexed 1, hence a vertex with 0 index is flag for no flow
function forward_flow(vertex)
    v_str = string(vertex)
    forward = Dict(
        "1" =>4,
        "2" =>3,
        "3" =>6,
        "4" =>5,
        "5" =>8,
        "6" =>7,
        "7" =>0,
        "8" =>0)
    forward[v_str]
end





function generate_grover_secret_angles(search::String)

    Dict("00"=>(1.0*π,1.0*π),"01"=>(1.0*π,0),"10"=>(0,1.0*π),"11"=>(0,0)) |>
    x -> x[search] |>
    x -> [0,0,1.0*x[1],1.0*x[2],0,0,1.0*π,1.0*π] |>
    x -> Float64.(x)
end

search = "10"
secret_angles = generate_grover_secret_angles(search)



para= (
    graph=graph,
    forward_flow = forward_flow,
    input = input,
    output = output,
    secret_angles=secret_angles,
    state_type = state_type,
    total_rounds = total_rounds,
    computation_rounds = computation_rounds)

ubqc_outcome = run_ubqc(para)
vbqc_outcome = run_verification_simulator(para)
mbqc_outcome = run_mbqc(para)



