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

search = "11"
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


# Noiseless and trust worthy server
mbqc_outcome = run_mbqc(para)
ubqc_outcome = run_ubqc(para)
vbqc_outcome = run_verification_simulator(para)

malicious_angles = π/8
malicious_vbqc_outcome = run_verification_simulator(MaliciousServer(),para,malicious_angles)


# Test 
test_sim = []
comp_sim = []
angle_range = range(0.0,2*π,length=100)
for a in angle_range
    malicious_vbqc_outcome = run_verification_simulator(MaliciousServer(),para,a) 
    out_test = malicious_vbqc_outcome[:test_verification] isa Ok ? 1.0 : 0.0
    out_comp = malicious_vbqc_outcome[:computation_verification] isa Ok ? 1.0 : 0.0
    push!(test_sim,out_test)
    push!(comp_sim,out_comp)
end



# Test round results
f = Figure(resolution = (800,800),fontsize = 22)
ax = Axis(f[1,1],xlabel = "Angle",xticks = ([0,π/4,π/2,3*π/4,π,5*π/4,3*π/2,7*π/4,2*π],["0","π/4","π/2","3π/4","π","5π/4","3π/2","7π/4","2π"]),ylabel = "Round Outcome", yticks = ([0.0,1.0],["Abort","Ok"]),title = "Malicious Server Verification Results", subtitle = "Inserts an additional angle to measurement basis")
results_scatter = scatter!(ax,angle_range,Float64.(test_sim))
Legend(f[2,1],[results_scatter],["Test"],orientation=:horizontal,halign=:left)
save("examples/malicious_server_added_angle_range_0to2pi_test_rounds.png",f)


# Computation results
f = Figure(resolution = (800,800),fontsize = 22)
ax = Axis(f[1,1],xlabel = "Angle",xticks = ([0,π/4,π/2,3*π/4,π,5*π/4,3*π/2,7*π/4,2*π],["0","π/4","π/2","3π/4","π","5π/4","3π/2","7π/4","2π"]),ylabel = "Round Outcome", yticks = ([0.0,1.0],["Abort","Ok"]),title = "Malicious Server Verification Results", subtitle = "Inserts an additional angle to measurement basis")
results_scatter = scatter!(ax,angle_range,Float64.(comp_sim))
Legend(f[2,1],[results_scatter],["Computation"],orientation=:horizontal,halign=:left)
save("examples/malicious_server_added_angle_range_0to2pi_computation_rounds.png",f)