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

noise_model = noise_model()
noisy_vbqc_outcome = run_verification_simulator(NoisyServer(),Verbose(),para,malicious_angles)


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

@testset "test_run_verification_simulator" begin
    noise_model = noise_model()
    noisy_vbqc_outcome = run_verification_simulator(NoisyServer(),Verbose(),para,malicious_angles)
end


# ERRORRRRRRRRRRWS

num_qubits = 2
quantum_env = create_quantum_env(Client())
ρ = create_quantum_state(Client(),DensityMatrix(),quantum_env,num_qubits)
init_plus_phase_state!.(Ref(NoPhase()),Ref(ρ),Base.OneTo(num_qubits))
q = 1
pxyz = [0.2,0.2,0.2]
p = 0.2
model = Depolarising(SingleQubit(),p)
model = Dephasing(SingleQubit(),p)
model = Damping(SingleQubit(),p)
model = Pauli(SingleQubit(),pxyz)
params = QubitNoiseParameters(Quest(),ρ,q)
noise_model = NoiseModel(model,params)
get_all_amps(state_type,ρ)
add_noise!(Server(),noise_model)
get_all_amps(state_type,ρ)
add_noise!(Server(),noise_model)
get_all_amps(state_type,ρ)


model_vec = [Depolarising,Dephasing,Damping,Pauli]
qubit_typ = [SingleQubit() for i in eachindex(model_vec)]
model_pro = [0.1,0.2,0.21,[0.2,0.2,0.2]]
models = map((x,y,z) -> x(y,z),model_vec,qubit_typ,model_pro)

params = QubitNoiseParameters(Quest(),ρ,q)
noise_model = NoiseModel.(models,Ref(params))
[add_noise!(Server(),nm) for nm in noise_model[1]]
map(x -> add_noise!(Server(),x),noise_model[1])
get_all_amps(state_type,ρ)

noise_model isa Vector 
QuESTMbqcBqpVerification.length(noise_model[1]) == 1
[i for i in eachindex(x)]

using LinearAlgebra

# Probability of bit-flip
p = 0.1  # You can replace :p with an actual numerical value

# Define Pauli X matrix
X = [0 1; 1 0]

# Kraus operators
K0 = sqrt(1 - p) * ident_2x2()
K1 = sqrt(p) * X

# Check completeness condition
@assert K0' * K0 + K1' * K1 ≈ I
