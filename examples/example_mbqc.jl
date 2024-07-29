##################################################################
# Filename  : example_mbqc.jl
# Author    : Jonathan Miller
# Date      : 2024-06-05
# Aim       : aim_script
#           : Provide simple example of MBQC
#           : To show functionality as it is used in VeriQuEST
#           : Simple path graph with π/2 for each angle
#           : Last qubit should be 0. 
#           : Tested on state vector and density matrix
##################################################################

using Pkg
Pkg.activate(".")
include("../src/VeriQuEST.jl")
using .VeriQuEST
using Graphs
using MetaGraphs


# Set up input values
graph = Graph(2)
add_edge!(graph,1,2)

io = InputOutput(Inputs((1),(0)),Outputs(2))
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


outcomes_dm = []
outcomes_sv = []
for i in Base.OneTo(10)
    mg_dm = compute!(mbqc_comp_type,no_network,dm,ch,cr)
    mg_sv = compute!(mbqc_comp_type,no_network,sv,ch,cr)
    push!(outcomes_dm,get_prop(mg_dm,2,:outcome))
    push!(outcomes_sv,get_prop(mg_sv,2,:outcome))
end


@assert all([i == 0 for i in outcomes_dm])
@assert all([i == 0 for i in outcomes_sv])
