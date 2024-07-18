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
total_rounds = 10
computation_rounds = 1
trapification_strategy = TestRoundTrapAndDummycolouring()



# Initial setups
ct = LeichtleVerification(
    total_rounds,
    computation_rounds,
    trapification_strategy,
    qgraph,flow,measurement_angles)
nt_bp = BellPairExplicitNetwork()
nt_im = ImplicitNetworkEmulation()
st = DensityMatrix()
ch = NoisyChannel(NoNoise(NoQubits()))

for i in Base.OneTo(100)
    ver_res1 = run_verification_simulator(ct,nt_bp,st,ch)
    ver_res2 = run_verification_simulator(ct,nt_im,st,ch)
    @assert ver_res1.tests isa Ok
    @assert ver_res2.tests isa Ok
end