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

using QuEST_jl
import QuEST_jl.QuEST64
QuEST = QuEST_jl.QuEST64
qreal = QuEST.QuEST_Types.qreal
using Test
using StatsBase
using Graphs
using CairoMakie

include("src/QuESTMbqcBqpVerification.jl")
using .QuESTMbqcBqpVerification 

#using QuESTMbqcBqpVerification 

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


function backward_flow(vertex)
    v_str = string(vertex)
    backward = Dict(
        "1" =>0,
        "2" =>0,
        "3" =>2,
        "4" =>1,
        "5" =>4,
        "6" =>3,
        "7" =>6,
        "8" =>5)
    backward[v_str]
end



state_type = DensityMatrix()
input_indices = () # a tuple of indices 
input_values = () # a tuple of input values
output_indices = (7,8) # Grovers: 7,8



function generate_grover_secret_angles(search::String)

    Dict("00"=>(1.0*π,1.0*π),"01"=>(1.0*π,0),"10"=>(0,1.0*π),"11"=>(0,0)) |>
    x -> x[search] |>
    x -> [0,0,1.0*x[1],1.0*x[2],0,0,1.0*π,1.0*π] |>
    x -> Float64.(x)
end

search = "00"
secret_angles = generate_grover_secret_angles(search)
total_rounds,computation_rounds = 100,50
test_rounds_theshold = total_rounds -computation_rounds

para= (
    graph=graph,
    forward_flow = forward_flow,
    backward_flow=backward_flow,
    input_indices = input_indices,
    input_values = input_values,
    output_indices =output_indices,
    secret_angles=secret_angles,
    state_type = state_type,
    total_rounds = total_rounds,
    computation_rounds = computation_rounds,
    test_rounds_theshold = test_rounds_theshold)

run_verification_simulator(para)


