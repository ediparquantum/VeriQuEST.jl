##################################################################
# Filename  : example_vbqc.jl
# Author    : Jonathan Miler
# Date      : 2024-07-08
# Aim       : aim_script
#           : Run a simple example of VBQC on
#           : both the implicit and explicit network
##################################################################

# NEEDS WORK TO SHOW!!!!!


using Pkg
Pkg.activate(".")
include("VeriQuEST.jl")
using .VeriQuEST
using Graphs


# Set up input values
graph = Graph(2)
add_edge!(graph,1,2)
io = InputOutput(Inputs(),Outputs(2))
qgraph = QuantumGraph(graph,io)
function forward_flow(vertex)
    v_str = string(vertex)
    forward = Dict(
        "1" =>2,
        "2"=>0)
    forward[v_str]
end
flow = Flow(forward_flow)
measurement_angles = Angles([π/2,π/2])
total_rounds = 10
computation_rounds = 1
trapification_strategy = TestRoundTrapAndDummycolouring()
ct = LeichtleVerification(
    total_rounds,
    computation_rounds,
    trapification_strategy,
    qgraph,flow,measurement_angles)
nt_bp = BellPairExplicitNetwork()
nt_im = ImplicitNetworkEmulation()
st = DensityMatrix()
ch = NoisyChannel(NoNoise(NoQubits()))



# No noise
vr = run_verification_simulator(ct,nt_im,st,ch)
vr = run_verification_simulator(ct,nt_bp,st,ch)



# Prob scaling
p_scale = 0.5
p = [p_scale*rand() for i in vertices(graph)]


# Damping
model = Damping(SingleQubit(),p)
ch = NoisyChannel(model)
vr = run_verification_simulator(ct,nt_im,st,ch)
vr = run_verification_simulator(ct,nt_bp,st,ch)


# Dephasing
model = Dephasing(SingleQubit(),p)
ch = NoisyChannel(model)
vr = run_verification_simulator(ct,nt_im,st,ch)
vr = run_verification_simulator(ct,nt_bp,st,ch)


# Depolarising
model = Depolarising(SingleQubit(),p)
ch = NoisyChannel(model)
vr = run_verification_simulator(ct,nt_im,st,ch)
vr = run_verification_simulator(ct,nt_bp,st,ch)



# Post Angle Update
model = PostAngleUpdate(SingleQubit(),0.1)
ch = NoisyChannel(model)
vr = run_verification_simulator(ct,nt_im,st,ch)
vr = run_verification_simulator(ct,nt_bp,st,ch)


# Add bit flip
model = AddBitFlip(SingleQubit(),0.5)
ch = NoisyChannel(model)
vr = run_verification_simulator(ct,nt_im,st,ch)
vr = run_verification_simulator(ct,nt_bp,st,ch)



# Pauli 
#= 
ERROR: MethodError: no method matching add_pauli_noise!(::SingleQubit, ::QuEST.Qureg, ::Int32, ::Float64)

Closest candidates are:
  add_pauli_noise!(::SingleQubit, ::QuEST.Qureg, ::Any, ::Vector)
   @ Main.VeriQuEST ~/Projects/VeriQuEST.jl/src/noisy_functions.jl:70 
=#
p_xyz(p_scale) = p_scale/10 .* [rand(),rand(),rand()]
p = [p_xyz(p_scale) for i in vertices(graph)]
model = Pauli(SingleQubit(),p)
ch = NoisyChannel(model)
vr = run_verification_simulator(ct,nt_im,st,ch)
vr = run_verification_simulator(ct,nt_bp,st,ch)


noise_function = VeriQuEST.get_noise_model(model)
qubit_type = model.type
prob = model.param




Kraus
MixtureDensityMatrices
 
 
using QuEST
env = createQuESTEnv()
ψ = createDensityQureg(1,env)
p = [0.1,0.1,0.1]
q = 1
VeriQuEST.add_pauli_noise!(SingleQubit(),ψ,q,p[1])
get_qureg_matrix(ψ)






    # Vector of noise models
    model_vec = [Damping,Dephasing,Depolarising,Pauli]
    p_damp = [p_scale*rand() for i in vertices(para[:graph])]
    p_deph = [p_scale*rand() for i in vertices(para[:graph])]
    p_depo = [p_scale*rand() for i in vertices(para[:graph])]
    p_pauli = [p_xyz(p_scale) for i in vertices(para[:graph])]
    prob_vec = [p_damp,p_deph,p_depo,p_pauli]

    models = Vector{AbstractNoiseModels}()
    for m in eachindex(model_vec)
        push!(models,model_vec[m](SingleQubit(),prob_vec[m]))
    end
    server = NoisyChannel(models)
    vbqc_outcome = run_verification_simulator(server,Verbose(),para)




for i in Base.OneTo(100)
    ver_res1 = run_verification_simulator(ct,nt_bp,st,ch)
    ver_res2 = run_verification_simulator(ct,nt_im,st,ch)
    @assert ver_res1.tests isa Ok
    @assert ver_res2.tests isa Ok
end

vr = run_verification_simulator(ct,nt_bp,st,ch)
get_tests(vr) 
get_computations(vr)
get_tests_verbose(vr)
get_computations_verbose(vr) 
get_computations_mode(vr) 









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
include("../src/RobustBlindVerification.jl")

using .RobustBlindVerification



// # Set up
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
// # end

// # Run verification tests
    # Noiseless and trust worthy server
    mbqc_outcome = run_mbqc(para)
    ubqc_outcome = run_ubqc(para)
    vbqc_outcome = run_verification_simulator(TrustworthyServer(),Verbose(),para)

    vbqc_outcome[:test_verification]
    malicious_angles = π/2
    malicious_vbqc_outcome = run_verification_simulator(MaliciousServer(),Verbose(),para,malicious_angles)

    outcomes = []
    angle_range = range(0.0,2*π,length=10)
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
// #end

// # Run verification noise models

    # Prob scaling
    p_scale = 0.05

    # Damping
    p = [p_scale*rand() for i in vertices(para[:graph])]
    model = Damping(SingleQubit(),p)
    server = NoisyChannel(model)
    vbqc_outcome = run_verification_simulator(server,Verbose(),para)


    # Dephasing
    p = [p_scale*rand() for i in vertices(para[:graph])]
    model = Dephasing(SingleQubit(),p)
    server = NoisyChannel(model)
    vbqc_outcome = run_verification_simulator(server,Verbose(),para)

    # Depolarising
    p = [p_scale*rand() for i in vertices(para[:graph])]
    model = Depolarising(SingleQubit(),p)
    server = NoisyChannel(model)
    vbqc_outcome = run_verification_simulator(server,Verbose(),para)

    # Pauli
    p_xyz(p_scale) = p_scale .* [rand(),rand(),rand()]
    p = [p_xyz(p_scale) for i in vertices(para[:graph])]
    model = Pauli(SingleQubit(),p)
    server = NoisyChannel(model)
    vbqc_outcome = run_verification_simulator(server,Verbose(),para)


    # Vector of noise models
    model_vec = [Damping,Dephasing,Depolarising,Pauli]
    p_damp = [p_scale*rand() for i in vertices(para[:graph])]
    p_deph = [p_scale*rand() for i in vertices(para[:graph])]
    p_depo = [p_scale*rand() for i in vertices(para[:graph])]
    p_pauli = [p_xyz(p_scale) for i in vertices(para[:graph])]
    prob_vec = [p_damp,p_deph,p_depo,p_pauli]

    models = Vector{AbstractNoiseModels}()
    for m in eachindex(model_vec)
        push!(models,model_vec[m](SingleQubit(),prob_vec[m]))
    end
    server = NoisyChannel(models)
    vbqc_outcome = run_verification_simulator(server,Verbose(),para)
// # end
