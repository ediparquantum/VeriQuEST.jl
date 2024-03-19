

using Pkg
Pkg.activate(".")
using Graphs
using MetaGraphs
using QuEST
using Chain
#using VeriQuEST
#import VeriQuEST: get_input_indices, get_input_values, MetaGraph
#using TeleQuEST

include("../src/abstract_types.jl")
include("../src/structs.jl")
include("../src/draw_random_numbers.jl")
include("../src/asserts_errors_warnings.jl")
include("../src/create_quantum_state_env.jl")
include("../src/input_output_mbqc.jl")
include("../src/colourings.jl")
include("../src/graphs.jl")
include("../src/angles.jl")
include("../src/flow.jl")
include("../src/computation_types.jl")
include("../src/trapification_strategies.jl")
include("../src/abstract_parameter_resources.jl")
include("../src/network_emulation.jl")
include("../src/property_graph.jl")
include("../src/entangle.jl")
include("../src/noisy_functions.jl")
include("../src/measurements.jl")
include("../src/run_quantum_computation.jl")



graph = Graph(3)
add_edge!(graph,1,2)
add_edge!(graph,2,3)
io = InputOutput(Inputs(),Outputs(3))
qgraph = QuantumGraph(graph,io)
function forward_flow(vertex)
    v_str = string(vertex)
    forward = Dict(
        "1" =>2,
        "2" =>3,
        "3" =>0)
    forward[v_str]
end
flow = Flow(forward_flow)
measurement_angles = Angles([π,0,π])
total_rounds,computation_rounds = 100,50


p_scale = 0.1
# Vector of noise models
model_vec = [Damping,Dephasing,Depolarising,PostAngleUpdate,AddBitFlip]
p_damp = [p_scale*rand() for i in 1:3]
p_deph = [p_scale*rand() for i in 1:3]
p_depo = [p_scale*rand() for i in 1:3]
p_rang = [p_scale*rand() for i in 1:3]
p_flip = [p_scale*rand() for i in 1:3]
prob_vec = [p_damp,p_deph,p_depo,p_rang,p_flip]

models = Vector{AbstractNoiseModels}()
for m in eachindex(model_vec)
    push!(models,model_vec[m](SingleQubit(),prob_vec[m]))
end
channel = NoisyChannel(models)



mbqc_comp_type = MeasurementBasedQuantumComputation(qgraph,flow,measurement_angles)
ubqc_comp_type = BlindQuantumComputation(qgraph,flow,measurement_angles)
vbqc_comp_type = LeichtleVerification(total_rounds,computation_rounds,qgraph,flow,measurement_angles)
implicit_network = ImplicitNetworkEmulation()
no_network = NoNetworkEmulation()
bell_pair_explicit_network = BellPairExplicitNetwork()





resource = ParameterResources(mbqc_comp_type,no_network,DensityMatrix())
mg = generate_property_graph!(Client(),ComputationRound(),resource)
initialise_add_noise_entangle!(mg,channel)
run_computation!(mg,channel)
reset_quantum_state!(mg)

resource = ParameterResources(mbqc_comp_type,DensityMatrix())
mg = generate_property_graph!(Client(),ComputationRound(),resource)
initialise_add_noise_entangle!(mg,channel)
run_computation!(mg,channel)
reset_quantum_state!(mg)

resource = ParameterResources(ubqc_comp_type,implicit_network,DensityMatrix())
mg = generate_property_graph!(Client(),ComputationRound(),resource)
initialise_add_noise_entangle!(mg,channel)
run_computation!(mg,channel)
reset_quantum_state!(mg)

resource = ParameterResources(vbqc_comp_type,bell_pair_explicit_network,DensityMatrix())
mg = generate_property_graph!(Client(),ComputationRound(),resource)
initialise_add_noise_entangle!(mg,channel)
run_computation!(mg,channel)
reset_quantum_state!(mg)



resource = ParameterResources(vbqc_comp_type,bell_pair_explicit_network,DensityMatrix())
mg = generate_property_graph!(Client(),TestRound(),resource)
initialise_add_noise_entangle!(mg,channel)
run_computation!(mg,channel)
reset_quantum_state!(mg)






# No noise in state vector - add uncorrelated noise bit-flip stuff
channel = NoisyChannel(NoNoise(NoQubits()))
resource = ParameterResources(mbqc_comp_type,no_network,StateVector())
mg = generate_property_graph!(Client(),ComputationRound(),resource) 
initialise_add_noise_entangle!(mg,channel)
run_computation!(mg,channel)
reset_quantum_state!(mg)



resource = ParameterResources(mbqc_comp_type,StateVector())
mg = generate_property_graph!(Client(),ComputationRound(),resource)
initialise_add_noise_entangle!(mg,channel)
run_computation!(mg,channel)
reset_quantum_state!(mg)


channel = NoisyChannel(PostAngleUpdate(SingleQubit(),p_flip))
resource = ParameterResources(ubqc_comp_type,implicit_network,StateVector())
mg = generate_property_graph!(Client(),ComputationRound(),resource)
initialise_add_noise_entangle!(mg,channel)
run_computation!(mg,channel)
reset_quantum_state!(mg)


    
# now execute the computation


# finish noise for state vectors
# then look at the verification functions
