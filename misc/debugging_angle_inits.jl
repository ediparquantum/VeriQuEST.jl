##################################################################
# Filename  : debugging_angle_inits.jl
# Author    : Jonathan Miller
# Date      : 2024-07-05
# Aim       : aim_script
#           : Debug the explicit network
#           :
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



hilbert_schmidt_distance(A,B) = sqrt(sum(abs2.(A-B)))


# If loop runs than two random angles will be used and show 
# That I can create 
for i in Base.OneTo(10)
    angle_1,angle_2 = 2*π*rand(2)

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
    measurement_angles = Angles([angle_1,angle_2])


    # Initial setups
    ct = BlindQuantumComputation(qgraph,flow,measurement_angles)
    st = DensityMatrix()
    ch = NoisyChannel(NoNoise(NoQubits()))
    rt = ComputationRound()
    nt = BellPairExplicitNetwork()


    resource = ParameterResources(ct,nt,st) 
    mg = generate_property_graph!(Client(),rt,resource)
    initialised_state = initialise_state!(mg)
    inited_qureg_1 = QuEST.get_partial_trace(initialised_state.qureg,initialised_state.server_indices)


    # The edge iterator is not entangling correctly, It is not considering the newtwork emulator!!!!!!!



    # Do direct using updated angles based on the outcomes
    env = createQuESTEnv() # Create QuEST environment
    ρ = createDensityQureg(nv(mg),env) # Make my own standard
    [QuEST.hadamard(ρ,i) for i in vertices(mg)]
    [QuEST.rotateZ(ρ,i,initialised_state.adapted_prep_angles[i]) for i in vertices(mg)]
    inited_qureg_2 = QuEST.get_qureg_matrix(ρ) # This is what it should be


    @assert isapprox(hilbert_schmidt_distance(inited_qureg_1,inited_qureg_2),0.0,atol=1e-10)
    @assert isapprox(inited_qureg_1,inited_qureg_2,atol=1e-10)

end



resource.computation_type # Metadata from input regarding graph and MBQC inputs
resource.network_type # Network container: starts full of missing
resource.state_type # Quantum state backen (state vector or density matrix)

resource.computation_type 
resource.computation_type.graph # Type: QuantumGraph
resource.computation_type.graph.graph # Type: SimpleGraph{Int64}
resource.computation_type.graph.io # Type: InputOutput
resource.computation_type.graph.io.inputs # Type: Inputs
resource.computation_type.graph.io.inputs.indices # Type: Int64, if more than 1, then Vector or missing
resource.computation_type.graph.io.outputs # Type: Outputs
resource.computation_type.graph.io.outputs.indices # Type: Int64, if more than 1, then Vector
resource.computation_type.graph.colouring # Type: QuantumColouring 
resource.computation_type.graph.colouring.computation_round # Type: ComputationColouring
resource.computation_type.graph.colouring.computation_round.colours # Type: Int64[]
resource.computation_type.graph.colouring.test_round # Type: TestColouring
resource.computation_type.graph.colouring.test_round.colours # Type:  Vector{Vector{Int64}}
resource.computation_type.flow # Type: Flow
resource.computation_type.flow.forward # Type: Function
resource.computation_type.flow.backward # Type: var"#backward_flow#21"{typeof(forward_flow), SimpleGraph{Int64}}
resource.computation_type.measurement_angles # Type: Angles
resource.computation_type.measurement_angles.angles # Vector Floats

mg # property graph - holds all of the data
props(mg) # get props for graph
get_prop(mg,:round_type) # hold round_type information
get_prop(mg,:output_inds) # List of indices to be measured for BPQ outcome
get_prop(mg,:computation_type) # same as resource.computation_type Metadata from input regarding graph and MBQC inputs
get_prop(mg,:state_type) # Quantum state backen (state vector or density matrix)
get_prop(mg,:network_type) # Network container: starts full of missing

props(mg,1) # props associated with vertex 1
props(mg,1) |> keys
get_prop(mg,1,:vertex_io_type) # Does the qubit have classical input values (NoInputQubits,InputQubits)
get_prop(mg,1,:X_correction) # X Corrections qubit (0 means no qubit used in correction)
get_prop(mg,1,:secret_angle) # Angle not shared with server and determined by user
get_prop(mg,1,:vertex_type) # Type of qubit - Computational,MBQC,Test or Trap
get_prop(mg,1,:forward_flow) # Vertex that is output of forward flow
get_prop(mg,1,:backward_flow) # Vertex that is output of backrward flow (no value means no back flow )
get_prop(mg,1,:init_qubit) # Values to init qubit (if Float it is an angle, if Int the qubitis inits as 0 or 1)
get_prop(mg,1,:Z_correction) # Z Corrections qubit (0 means no qubit used in correction)
get_prop(mg,1,:outcome) # Outcome from running circuit (Int64 - circuit has not been run yet)
