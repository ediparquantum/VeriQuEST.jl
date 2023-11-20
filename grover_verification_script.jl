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
vbqc_outcome = run_verification_simulator(TrustworthyServer(),Verbose(),para)

malicious_angles = π/8
malicious_vbqc_outcome = run_verification_simulator(MaliciousServer(),Verbose(),para,malicious_angles)

# Test 
outcomes = []
angle_range = range(0.0,2*π,length=100)
for a in angle_range
    malicious_vbqc_outcome = run_verification_simulator(MaliciousServer(),Verbose(),para,a) 
   push!(outcomes,malicious_vbqc_outcome)
end

test_sim = []
comp_sim = []
test_counts = []
comp_counts = []
for o in outcomes
    out_test = Float64(o[:test_verification] isa Ok ? 1.0 : 0.0)
    out_comp = Float64(o[:computation_verification] isa Ok ? 1.0 : 0.0)
    push!(test_sim,out_test)
    push!(comp_sim,out_comp)
    push!(test_counts,o[:test_verification_verb][:failed])
    push!(comp_counts,o[:computation_verification_verb][:failed])
end





f = plot_verification_results(MaliciousServer(),Terse(),angle_range,test_sim,"Test")
save("examples/terse_malicious_server_added_angle_range_0to2pi_test_rounds.png",f)
f = plot_verification_results(MaliciousServer(),Terse(),angle_range,comp_sim,"Computation")
save("examples/terse_malicious_server_added_angle_range_0to2pi_computation_rounds.png",f)
f = plot_verification_results(MaliciousServer(),Verbose(),angle_range,test_counts,"Test")
save("examples/verbose_malicious_server_added_angle_range_0to2pi_test_rounds.png",f)
f = plot_verification_results(MaliciousServer(),Verbose(),angle_range,comp_counts,"Computation")
save("examples/verbose_malicious_server_added_angle_range_0to2pi_computation_rounds.png",f)

function two_pi_x()
    ([0,π/4,π/2,3*π/4,π,5*π/4,3*π/2,7*π/4,2*π],["0","π/4","π/2","3π/4","π","5π/4","3π/2","7π/4","2π"])
end

function ok_abort_y()
    ([0.0,1.0],["Abort","Ok"])
end


function plot_verification_results(::MaliciousServer,::Verbose,xdata,ydata,label)
    ∑ydata = sum(ydata)
    normy = ydata ./ ∑ydata
    f = Figure(resolution = (1200,1200),fontsize = 35)
    ax = Axis(
        f[1,1],
        xlabel = "Angle",
        ylabel = "Failed Rounds", 
        title = "Malicious Server Verification Results", 
        subtitle = "Inserts an additional angle to measurement basis",
        xticks = two_pi_x(),aspect=1)
    results_scatter = barplot!(ax,xdata,Float64.(normy))
    Legend(f[2,1],
    [results_scatter],[label],
    orientation=:horizontal,halign=:left)
    f
end

function plot_verification_results(::MaliciousServer,::Terse,xdata,ydata,label)
    f = Figure(resolution = (1200,1200),fontsize = 35)
    ax = Axis(
        f[1,1],
        xlabel = "Angle",
        ylabel = "Round Outcome", 
        title = "Malicious Server Verification Results", 
        subtitle = "Inserts an additional angle to measurement basis",
        xticks = two_pi_x(),
        yticks = ok_abort_y(),aspect=1)
    results_scatter = scatter!(ax,xdata,Float64.(ydata))
    Legend(f[2,1],
    [results_scatter],[label],
    orientation=:horizontal,halign=:left)
    f
end