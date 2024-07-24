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

vr = run_verification_simulator(ct,nt_bp,st,ch)
get_tests(vr) 
get_computations(vr)
get_tests_verbose(vr)
get_computations_verbose(vr) 
get_computations_mode(vr) 