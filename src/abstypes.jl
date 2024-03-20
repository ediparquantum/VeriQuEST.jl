

using Pkg
Pkg.activate(".")
using Graphs
using MetaGraphs
using QuEST
using Chain
using Random
using StatsBase


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
include("../src/verification.jl")



graph = Graph(2)
add_edge!(graph,1,2)

io = InputOutput(Inputs(),Outputs(2))
qgraph = QuantumGraph(graph,io)
function forward_flow(vertex)
    v_str = string(vertex)
    forward = Dict(
        "1" =>2,
        "2" =>0)
    forward[v_str]
end
flow = Flow(forward_flow)
measurement_angles = Angles([π/2,π/2])
total_rounds,computation_rounds = 100,50

# Dnesity matrix noise
p_scale = 0.0
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

# State vector noise
channel_no_noise = NoisyChannel(NoNoise(NoQubits()))
model_angle = PostAngleUpdate(SingleQubit(),p_rang)
model_bit = AddBitFlip(SingleQubit(),p_flip)
channel_angle_bit = NoisyChannel(AbstractNoiseModels[model_angle,model_bit])

mbqc_comp_type = MeasurementBasedQuantumComputation(qgraph,flow,measurement_angles)
ubqc_comp_type = BlindQuantumComputation(qgraph,flow,measurement_angles)
vbqc_comp_type = LeichtleVerification(total_rounds,computation_rounds,qgraph,flow,measurement_angles)
implicit_network = ImplicitNetworkEmulation()
no_network = NoNetworkEmulation()
bell_pair_explicit_network = BellPairExplicitNetwork()
dm = DensityMatrix()
sv = StateVector()
cr = ComputationRound()
tr = TestRound()


mbqc_dm_nn_dm_mg = compute!(mbqc_comp_type,no_network,dm,channel,cr)
ubqc_dm_im_dm_mg = compute!(ubqc_comp_type,implicit_network,dm,channel,cr)
ubqc_dm_bp_dm_mg = compute!(ubqc_comp_type,bell_pair_explicit_network,dm,channel,cr)
vbqc_dm_im_cr_mg = compute!(vbqc_comp_type,implicit_network,dm,channel,cr)
vbqc_dm_im_tr_mg = compute!(vbqc_comp_type,implicit_network,dm,channel,tr)
vbqc_dm_im_cr_mg = compute!(vbqc_comp_type,bell_pair_explicit_network,dm,channel,cr)
vbqc_dm_im_tr_mg = compute!(vbqc_comp_type,bell_pair_explicit_network,dm,channel,tr)
mbqc_dm_nn_sv_mg = compute!(mbqc_comp_type,no_network,sv,channel_no_noise,cr)
ubqc_dm_im_sv_mg = compute!(ubqc_comp_type,implicit_network,sv,channel_no_noise,cr)
mbqc_dm_nn_sv_mg = compute!(mbqc_comp_type,no_network,sv,channel_angle_bit,cr)
ubqc_dm_im_sv_mg = compute!(ubqc_comp_type,implicit_network,sv,channel_angle_bit,cr)


outs = Int64[]
# Now look at verification
for i in 1:10
    compute!(mbqc_comp_type,no_network,dm,channel_no_noise,cr) |>
    x -> get_prop(x,2,:outcome) |>
    x -> push!(outs,x)
end 

outs



ct = vbqc_comp_type
nt = bell_pair_explicit_network
st = DensityMatrix()
ch = channel_no_noise

rt = ComputationRound()
resource = ParameterResources(ct,nt,st)
mg = generate_property_graph!(Client(),rt,resource)
resource.computation_type.graph
props(mg)






compute!(mbqc_comp_type,no_network,dm,channel,cr) |> computation_results |> get_outcomes
compute!(ubqc_comp_type,implicit_network,dm,channel,cr) |> computation_results |> get_outcomes



vr = run_verification_simulator(vbqc_comp_type,bell_pair_explicit_network,DensityMatrix(),channel)

get_tests(vr) 
get_computations(vr)
get_tests_verbose(vr)
get_computations_verbose(vr) 
get_computations_mode(vr) 