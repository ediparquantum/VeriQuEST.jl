##################################################################
# Filename  : example_mbqc.jl
# Author    : Jonathan Miller
# Date      : 2024-06-05
# Aim       : aim_script
#           : Provide simple example of MBQC
#           : To show functionality as it is used in VeriQuEST
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
mbqc_comp_type = MeasurementBasedQuantumComputation(qgraph,flow,measurement_angles)
no_network = NoNetworkEmulation()
dm = DensityMatrix()
sv = StateVector()
ch = NoisyChannel(NoNoise(NoQubits()))
cr = MBQCRound()



outcomes = []
for i in Base.OneTo(1000)

    mg = compute!(mbqc_comp_type,no_network,dm,ch,cr)
    push!(outcomes,get_prop(mg,2,:outcome))
end

# MBQC no noise
mg1 = compute!(mbqc_comp_type,sv)
mg2 = compute!(mbqc_comp_type,dm)


# MBQC noise
compute!(mbqc_comp_type,dm,channel)

