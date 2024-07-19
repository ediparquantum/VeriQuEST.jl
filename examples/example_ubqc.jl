##################################################################
# Filename  : example_ubqc.jl
# Author    : Jonathan Miller
# Date      : 2024-06-07
# Aim       : aim_script
#           : Provide simple example of UBQC
#           : To show functionality as it is used in VeriQuEST
#           : Simple path graph with π/2 for each angle
#           : Last qubit should be 0. 
#           : Tested on state vector and density matrix
##################################################################


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


# Initial setups
ubqc_comp_type = BlindQuantumComputation(qgraph,flow,measurement_angles)
dm = DensityMatrix()
ch = NoisyChannel(NoNoise(NoQubits()))
cr = ComputationRound()



# Implicit network
implicit_network = ImplicitNetworkEmulation()
outcomes_imp_net = []
for i in Base.OneTo(10)
    mg_imp = compute!(ubqc_comp_type,implicit_network,dm,ch,cr)
    push!(outcomes_imp_net,get_prop(mg_imp,2,:outcome))
end

@assert all([i == 0 for i in outcomes_imp_net])



# Bell pair network
bell_pair_explicit_network = BellPairExplicitNetwork()
outcomes_bel_net = []
for i in Base.OneTo(10)
    mg_bp = compute!(ubqc_comp_type,bell_pair_explicit_network,dm,ch,cr)
    push!(outcomes_bel_net,get_prop(mg_bp,2,:outcome))
end


@assert all([i == 0 for i in outcomes_bel_net])

