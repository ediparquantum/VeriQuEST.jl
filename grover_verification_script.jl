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


// # Grover specific functions
    # Function to generate angles defining what search is completed
    function generate_angles(p)
        ϕ₃,ϕ₄ = p
        [0,0,1.0*ϕ₃,1.0*ϕ₄,0,0,1.0*π,1.0*π]
    end

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
// # end


state_type = StateVector()#DensityMatrix()
input_indices = () # a tuple of indices 
input_values = () # a tuple of input values
output_indices = (7,8) # Grovers: 7,8



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

# Define colouring
reps = 100
computation_colours = ones(nv(graph))
test_colours = get_vector_graph_colors(graph;reps=reps)



search = "10"
angle = Dict("00"=>(1.0*π,1.0*π),"01"=>(1.0*π,0),"10"=>(0,1.0*π),"11"=>(0,0))
secret_angles = Float64.(generate_angles(angle[search]))



p = (
    input_indices = input_indices,
    input_values = input_values,
    output_indices =output_indices,
    graph=graph,
    computation_colours=computation_colours,
    test_colours=test_colours,
    secret_angles=secret_angles,
    forward_flow = forward_flow,
    backward_flow=backward_flow)

client_resource = create_graph_resource(p)


total_rounds,computation_rounds = 100,50
round_types = draw_random_rounds(total_rounds,computation_rounds)

rounds_as_graphs = run_verification(Client(),Server(),
    round_types,client_resource,state_type)



test_rounds_theshold = 50
verify_rounds(Client(),TestRound(),rounds_as_graphs,test_rounds_theshold)
verify_rounds(Client(),ComputationRound(),rounds_as_graphs)
