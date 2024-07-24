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
include("../src/VeriQuEST.jl")
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
p_scale = 0.1
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




# Pauli 
p_xyz(p_scale) = p_scale/10 .* [rand(),rand(),rand()]
p = [p_xyz(p_scale) for i in vertices(graph)]
model = Pauli(SingleQubit(),p)
ch = NoisyChannel(model)
vr = run_verification_simulator(ct,nt_im,st,ch)
vr = run_verification_simulator(ct,nt_bp,st,ch)


# Vector of noise models
model_vec = [Damping,Dephasing,Depolarising,Pauli]
p_damp = [p_scale*rand() for i in vertices(graph)]
p_deph = [p_scale*rand() for i in vertices(graph)]
p_depo = [p_scale*rand() for i in vertices(graph)]
p_pauli = [p_xyz(p_scale) for i in vertices(graph)]
prob_vec = [p_damp,p_deph,p_depo,p_pauli]

models = Vector{AbstractNoiseModels}()
for m in eachindex(model_vec)
    push!(models,model_vec[m](SingleQubit(),prob_vec[m]))
end
ch = NoisyChannel(models)
vr = run_verification_simulator(ct,nt_im,st,ch)
vr = run_verification_simulator(ct,nt_bp,st,ch)




# Post Angle Update
model = PostAngleUpdate(SingleQubit(),0.1)
ch = NoisyChannel(model)
vr = run_verification_simulator(ct,nt_im,st,ch)
vr = run_verification_simulator(ct,nt_bp,st,ch)
st = StateVector()
vr = run_verification_simulator(ct,nt_im,st,ch)



# Add bit flip
model = AddBitFlip(SingleQubit(),0.5)
ch = NoisyChannel(model)
vr = run_verification_simulator(ct,nt_im,st,ch)
vr = run_verification_simulator(ct,nt_bp,st,ch)
st = StateVector()
vr = run_verification_simulator(ct,nt_im,st,ch)





##################################################################
# grovers_verification_example
##################################################################



# Set up input values
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
io = InputOutput(Inputs(),Outputs([7,8]))
qgraph = QuantumGraph(graph,io)
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
flow = Flow(forward_flow)
function generate_grover_secret_angles(search::String)

    Dict("00"=>(1.0*π,1.0*π),"01"=>(1.0*π,0),"10"=>(0,1.0*π),"11"=>(0,0)) |>
    x -> x[search] |>
    x -> [0,0,1.0*x[1],1.0*x[2],0,0,1.0*π,1.0*π] |>
    x -> Float64.(x)
end

search = "11"
measurement_angles = Angles(generate_grover_secret_angles(search))
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




# No noise
model = NoNoise(NoQubits())
ch = NoisyChannel(model)
vr = run_verification_simulator(ct,nt_im,st,ch)
vr = run_verification_simulator(ct,nt_bp,st,ch)


# Prob scaling
p_scale = 0.1
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





# Pauli 
p_xyz(p_scale) = p_scale/10 .* [rand(),rand(),rand()]
p = [p_xyz(p_scale) for i in vertices(graph)]
model = Pauli(SingleQubit(),p)
ch = NoisyChannel(model)
vr = run_verification_simulator(ct,nt_im,st,ch)
vr = run_verification_simulator(ct,nt_bp,st,ch)


# Vector of noise models
model_vec = [Damping,Dephasing,Depolarising,Pauli]
p_damp = [p_scale*rand() for i in vertices(graph)]
p_deph = [p_scale*rand() for i in vertices(graph)]
p_depo = [p_scale*rand() for i in vertices(graph)]
p_pauli = [p_xyz(p_scale) for i in vertices(graph)]
prob_vec = [p_damp,p_deph,p_depo,p_pauli]

models = Vector{AbstractNoiseModels}()
for m in eachindex(model_vec)
    push!(models,model_vec[m](SingleQubit(),prob_vec[m]))
end
ch = NoisyChannel(models)
vr = run_verification_simulator(ct,nt_im,st,ch)
vr = run_verification_simulator(ct,nt_bp,st,ch)



# Post Angle Update
model = PostAngleUpdate(SingleQubit(),0.1)
ch = NoisyChannel(model)
vr = run_verification_simulator(ct,nt_im,st,ch)
vr = run_verification_simulator(ct,nt_bp,st,ch)
st = StateVector()
vr = run_verification_simulator(ct,nt_im,st,ch)



# Add bit flip
model = AddBitFlip(SingleQubit(),0.5)
ch = NoisyChannel(model)
vr = run_verification_simulator(ct,nt_im,st,ch)
vr = run_verification_simulator(ct,nt_bp,st,ch)
st = StateVector()
vr = run_verification_simulator(ct,nt_im,st,ch)





