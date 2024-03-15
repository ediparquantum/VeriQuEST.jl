

using Pkg
Pkg.activate(".")
using Graphs
using VeriQuEST
import VeriQuEST: get_input_indices, get_input_values, MetaGraph
using TeleQuEST

include("../src/abstract_types.jl")
include("../src/no_fields_structs.jl")
include("../src/input_output_mbqc.jl")
include("../src/colourings.jl")
include("../src/graphs.jl")
include("../src/angles.jl")
include("../src/flow.jl")
include("../src/computation_types.jl")
include("../src/trapification_strategies.jl")
include("../src/abstract_parameter_resources.jl")
include("../src/generate_property_graph.jl")
include("../src/network_emulation.jl")




create_quantum_state(::StateVector,quantum_env,num_qubits) = createQureg(num_qubits, quantum_env)
create_quantum_state(::DensityMatrix,quantum_env,num_qubits) = createDensityQureg(num_qubits, quantum_env)




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

mbqc_comp_type = MeasurementBasedQuantumComputation(qgraph,flow,measurement_angles)
ubqc_comp_type = BlindQuantumComputation(qgraph,flow,measurement_angles)
vbqc_comp_type = LeichtleVerification(total_rounds,computation_rounds,qgraph,flow,measurement_angles)
implicit_network = ImplicitNetworkEmulation()
no_network = NoNetworkEmulation()
bell_pair_explicit_network = BellPairExplicitNetwork()



resource = ParameterResources(mbqc_comp_type,no_network,StateVector())
mg = generate_property_graph!(Client(),ComputationRound(),resource) 
initialise_state!(mg)
resource = ParameterResources(mbqc_comp_type,no_network,DensityMatrix())
mg = generate_property_graph!(Client(),ComputationRound(),resource)
initialise_state!(mg)
resource = ParameterResources(mbqc_comp_type,StateVector())
mg = generate_property_graph!(Client(),ComputationRound(),resource)
initialise_state!(mg)
resource = ParameterResources(mbqc_comp_type,DensityMatrix())
mg = generate_property_graph!(Client(),ComputationRound(),resource)
initialise_state!(mg)
resource = ParameterResources(ubqc_comp_type,implicit_network,StateVector())
mg = generate_property_graph!(Client(),ComputationRound(),resource)
initialise_state!(mg)
resource = ParameterResources(ubqc_comp_type,implicit_network,DensityMatrix())
mg = generate_property_graph!(Client(),ComputationRound(),resource)
initialise_state!(mg)
resource = ParameterResources(vbqc_comp_type,bell_pair_explicit_network,DensityMatrix())
mg = generate_property_graph!(Client(),ComputationRound(),resource)
initialise_state!(mg)
resource = ParameterResources(vbqc_comp_type,bell_pair_explicit_network,DensityMatrix())
mg = generate_property_graph!(Client(),TestRound(),resource)
initialise_state!(mg)






    








function run_verification(::Client,::Server,
    resource::AbstractParameterResources)

    round_types = draw_random_rounds(resource)
    

    round_graphs = []
    for round_type in round_types
        
        # Generate client meta graph
        mg = generate_property_graph!(Client(),round_type,resource)
        
        # Run quantum
        run_quantum_computation(Client(),Server(),mg)

        function run_quantum_computation(client::AbstractClient,server::AbstractServer,mg::MetaGraphs.MetaGraph{Int64, Float64})

        # Extract graph and qureg from client
        client_graph = produce_initialised_graph(Client(),client_meta_graph)
        client_qureg = produce_initialised_qureg(Client(),client_meta_graph)
        
        # Create server resources
        server_resource = create_resource(Server(),client_graph,client_qureg)
        server_quantum_state = server_resource["quantum_state"]
        num_qubits_from_server = server_quantum_state.numQubitsRepresented
        run_computation(Client(),Server(),client_meta_graph,num_qubits_from_server,server_quantum_state)
       
        initialise_blank_quantum_state!(server_quantum_state)

        mg
        end

        push!(round_graphs,client_meta_graph)
    end

    round_graphs
end




















env = createQuESTEnv()
num_qubits = 3
client_idx = 1
server_idx = [2,3]
angles = [0.0,0.0]
qureg = createDensityQureg(num_qubits,env)
te = TeleportationModel(BellStateTeleportation(qureg,BellPair(client_idx,missing),angles))
output = teleport!(te)


function run_verification_simulator(::TrustworthyServer,::Terse,para)
    # Define colouring
    reps = 100
    computation_colours = ones(nv(para[:graph]))
    test_colours = get_vector_graph_colors(para[:graph];reps=reps)
    chroma_number = length(test_colours)
    bqp = InherentBoundedError(1/3)
    test_rounds_theshold = compute_trap_round_fail_threshold(para[:total_rounds],para[:computation_rounds],chroma_number,bqp) 




    backward_flow(vertex) = compute_backward_flow(para[:graph],para[:forward_flow],vertex)

    p = (
        input_indices =  para[:input][:indices],
        input_values = para[:input][:values],
        output_indices =para[:output],
        graph=para[:graph],
        computation_colours=computation_colours,
        test_colours=test_colours,
        secret_angles=para[:secret_angles],
        forward_flow = para[:forward_flow],
        backward_flow=backward_flow)
        
    client_resource = create_graph_resource(p)

    round_types = draw_random_rounds(resource)


    rounds_as_graphs = run_verification( # Could have run_verification as a function and abstract the inputs
        Client(),Server(),
        round_types,client_resource,
        para[:state_type])




        test_verification = verify_rounds(Client(),TestRound(),Terse(),rounds_as_graphs,test_rounds_theshold)
        computation_verification = verify_rounds(Client(),ComputationRound(),Terse(),rounds_as_graphs)
        mode_outcome = get_mode_output(Client(),ComputationRound(),rounds_as_graphs)
    return (
        test_verification = test_verification,
        computation_verification = computation_verification,
        mode_outcome = mode_outcome)
end











"""
    initialise_quantum_state_meta_graph!(::Client, state_type::Union{StateVector,DensityMatrix}, mg)

This function initializes the quantum state of a meta graph for a client in the MBQC model. 
It first creates a quantum environment and a quantum state of the specified type. 
Then, for each vertex in the meta graph, it gets the vertex type, vertex IO type, and initial qubit value, 
and uses these to initialize the qubit in the quantum state. 
Finally, it sets the quantum state as a property of the meta graph.

# Arguments
- `::Client`: The Client object.
- `state_type::Union{StateVector,DensityMatrix}`: The type of quantum state to create.
- `mg`: The MetaGraph to which the properties will be added.

# Returns
- The updated MetaGraph.

# Examples
```julia
client = Client()
mg = MetaGraphs.MetaGraph(graph)
state_type = StateVector()
initialise_quantum_state_meta_graph!(client, state_type, mg)
```
"""
function initialise_quantum_state_meta_graph!(
    ::Client,
    state_type::Union{StateVector,DensityMatrix},
    mg)
    num_qubits = nv(mg)
    quantum_env = create_quantum_env(Client())
    quantum_state = create_quantum_state(Client(),state_type,quantum_env,num_qubits)
    for v in vertices(mg)
        v_type = get_prop(mg,v,:vertex_type)
        v_io_type = get_prop(mg,v,:vertex_io_type)
        qubit_input_value = get_prop(mg,v,:init_qubit)
        initialise_qubit(v_type,v_io_type,quantum_state,v,qubit_input_value)
    end
    set_prop!(mg,:quantum_state,quantum_state) # Set state to graph

    return mg
end


"""
    initialise_quantum_state_meta_graph!(mbqc::MBQC, client::Client, state_type::Union{StateVector,DensityMatrix}, mg)

This function initializes the quantum state of a meta graph for a client in the MBQC model. 
It first creates a quantum environment and a quantum state of the specified type. 
Then, for each vertex in the meta graph, it gets the vertex type and vertex IO type, 
and uses these to initialize the qubit in the quantum state. 
Finally, it sets the quantum state as a property of the meta graph.

# Arguments
- `::MBQC`: The MBQC object.
- `::Client`: The Client object.
- `state_type::Union{StateVector,DensityMatrix}`: The type of quantum state to create.
- `mg`: The MetaGraph to which the properties will be added.

# Returns
- The updated MetaGraph.

# Examples
```julia
mbqc = MBQC()
client = Client()
mg = MetaGraphs.MetaGraph(graph)
state_type = StateVector()
initialise_quantum_state_meta_graph!(mbqc, client, state_type, mg)
```
"""
function initialise_quantum_state_meta_graph!(
    ::MBQC,
    ::Client,
    state_type::Union{StateVector,DensityMatrix},
    mg)
    num_qubits = nv(mg)
    quantum_env = create_quantum_env(Client())
    quantum_state = create_quantum_state(Client(),state_type,quantum_env,num_qubits)
    for v in vertices(mg)
        v_type = get_prop(mg,v,:vertex_type)
        v_io_type = get_prop(mg,v,:vertex_io_type)
       # qubit_input_value = get_prop(mg,v,:init_qubit)
        initialise_qubit(MBQC(),v_type,v_io_type,quantum_state,v)
    end
    set_prop!(mg,:quantum_state,quantum_state) # Set state to graph

    return mg
end


"""
    entangle_graph!(::Client, mg)

This function entangles the quantum state of a meta graph for a client in the MBQC model. 
It first retrieves the quantum state from the meta graph and creates a graph from the meta graph. 
Then, for each edge in the graph, it applies a controlled phase flip operation on the source and destination vertices.

# Arguments
- `::Client`: The Client object.
- `mg`: The MetaGraph to which the properties will be added.

# Examples
```julia
client = Client()
mg = MetaGraphs.MetaGraph(graph)
entangle_graph!(client, mg)
```
"""
function entangle_graph!(::Client,mg)
    qureg = get_prop(mg,:quantum_state)
    graph = Graph(mg)

    edge_iter = edges(graph)
    for e in edge_iter
        src,dst = e.src,e.dst
        controlledPhaseFlip(qureg,src,dst)
    end
end



"""
    add_output_qubits!(::Client, mg, resource::MBQCResourceState)

This function adds output qubits to the meta graph for a client in the MBQC model. 
It retrieves the output indices from the resource graph and sets the `:output_inds` property of the meta graph to these indices.

# Arguments
- `::Client`: The Client object.
- `mg`: The MetaGraph to which the property will be added.
- `resource::MBQCResourceState`: The resource containing the graph and its coloring.

# Returns
- The updated MetaGraph.

# Examples
```julia
client = Client()
resource = MBQCResourceState(graph)
mg = MetaGraphs.MetaGraph(resource.graph.graph)
add_output_qubits!(client, mg, resource)
```
"""
function add_output_qubits!(
    ::Client,
    mg,
    resource::MBQCResourceState)
    output_inds = resource.graph.output.indices
    set_prop!(mg,:output_inds,output_inds)
end


"""
    generate_property_graph!(::Client, round_type, resource::MBQCResourceState, state_type::Union{StateVector,DensityMatrix})

This function generates a property graph for a client in the MBQC model based on the round type. 
It first creates a meta graph from the resource and adds the round type to it. 
Then, it adds output qubits, sets the vertex type and IO qubits type, initializes the qubits, 
adds flow vertices and correction vertices, initializes measurement outcomes, 
and initializes the quantum state of the meta graph. 
This function is run at the beginning of every round.

# Arguments
- `::Client`: The Client object.
- `round_type`: The round type.
- `resource::MBQCResourceState`: The resource containing the graph and its coloring.
- `state_type::Union{StateVector,DensityMatrix}`: The type of quantum state to create.

# Returns
- The updated MetaGraph.

# Examples
```julia
client = Client()
resource = MBQCResourceState(graph)
round_type = "round1"
state_type = StateVector()
generate_property_graph!(client, round_type, resource, state_type)
```
"""
function generate_property_graph!(
    ::Client,
    round_type,
    resource::MBQCResourceState,
    state_type::Union{StateVector,DensityMatrix})
    mg = MetaGraph(Client(),resource)
    add_round_type!(Client(),mg,round_type)
    add_output_qubits!(Client(),mg,resource)
    set_vertex_type!(Client(),resource,mg) # Set qubit type according to a random coloring
    set_io_qubits_type!(Client(),resource,mg) # Set if qubit is input or not
    init_qubit_meta_graph!(Client(),resource,mg) # Provide intial value for qubits
    add_flow_vertex!(Client(),mg,resource)
    add_correction_vertices!(Client(),mg,resource)
    init_measurement_outcomes!(Client(),mg,resource)
    initialise_quantum_state_meta_graph!(Client(),state_type,mg)
    
    return mg
end


"""
    generate_property_graph!(::Client, round_type::MBQC, resource::MBQCResourceState, state_type::Union{StateVector,DensityMatrix})

This function generates a property graph for a client in the MBQC model based on the round type. 
It first creates a meta graph from the resource and adds the round type to it. 
Then, it adds output qubits, sets the vertex type and IO qubits type, initializes the qubits, 
adds flow vertices and correction vertices, initializes measurement outcomes, 
initializes the quantum state of the meta graph, and entangles the graph. 
This function is run at the beginning of every round.

# Arguments
- `::Client`: The Client object.
- `round_type::MBQC`: The round type.
- `resource::MBQCResourceState`: The resource containing the graph and its coloring.
- `state_type::Union{StateVector,DensityMatrix}`: The type of quantum state to create.

# Returns
- The updated MetaGraph.

# Examples
```julia
client = Client()
resource = MBQCResourceState(graph)
round_type = MBQC()
state_type = StateVector()
generate_property_graph!(client, round_type, resource, state_type)
```
"""
function generate_property_graph!(
    ::Client,
    round_type::MBQC,
    resource::MBQCResourceState,
    state_type::Union{StateVector,DensityMatrix})
    mg = MetaGraph(Client(),resource)
    add_round_type!(Client(),mg,round_type)
    add_output_qubits!(Client(),mg,resource)
    set_vertex_type!(Client(),resource,mg) # Set qubit type according to a random coloring
    set_io_qubits_type!(Client(),resource,mg) # Set if qubit is input or not
    init_qubit_meta_graph!(Client(),resource,mg) # Provide intial value for qubits
    add_flow_vertex!(Client(),mg,resource)
    add_correction_vertices!(Client(),mg,resource)
    init_measurement_outcomes!(Client(),mg,resource)
    initialise_quantum_state_meta_graph!(MBQC(),Client(),state_type,mg)
    entangle_graph!(Client(),mg)    
    return mg
end






"""
    produce_initialised_graph(::Client, mg)

This function produces an initialised graph from a meta graph for a client in the MBQC model. 
It simply creates a new graph from the meta graph.

# Arguments
- `::Client`: The Client object.
- `mg`: The MetaGraph to be converted into a graph.

# Returns
- A new Graph created from the MetaGraph.

# Examples
```julia
client = Client()
mg = MetaGraphs.MetaGraph(graph)
produce_initialised_graph(client, mg)
```
"""
produce_initialised_graph(::Client,mg) = Graph(mg)



"""
    produce_initialised_qureg(client::Client, mg)

This function retrieves the quantum state from a meta graph for a client in the MBQC model. 
It uses the `get_prop` function to get the `:quantum_state` property from the meta graph.

# Arguments
- `client::Client`: The Client object.
- `mg`: The MetaGraph from which the quantum state will be retrieved.

# Returns
- The quantum state of the MetaGraph.

# Examples
```julia
client = Client()
mg = MetaGraphs.MetaGraph(graph)
produce_initialised_qureg(client, mg)
```
"""
produce_initialised_qureg(::Client,mg) = get_prop(mg,:quantum_state)


"""
    measure_along_ϕ_basis!(client::Client, ψ, v::Union{Int32,Int64}, ϕ::Float64)

This function measures a quantum state along a specific basis. 
It first applies a Z rotation to the state, then applies a Hadamard gate, 
and finally performs a measurement. The basis is determined by the angle ϕ.

# Arguments
- `client::Client`: The Client object.
- `ψ`: The quantum state to be measured.
- `v::Union{Int32,Int64}`: The vertex on which the operations are applied.
- `ϕ::Float64`: The angle determining the basis for measurement.

# Returns
- The result of the measurement.

# Examples
```julia
client = Client()
ψ = QuantumState()
v = 1
ϕ = π/4
measure_along_ϕ_basis!(client, ψ, v, ϕ)
```
"""
function measure_along_ϕ_basis!(::Client,ψ,v::Union{Int32,Int64},ϕ::Float64)
    rotateZ(ψ,v,-ϕ)
    hadamard(ψ,v)
    measure(ψ,v)
end



"""
    store_measurement_outcome!(client::Client, client_meta_graph, qubit, outcome)

This function stores the measurement outcome of a specific qubit in the client's meta graph. 
It uses the `set_p` function to set the property in the meta graph.

# Arguments
- `client::Client`: The Client object.
- `client_meta_graph`: The MetaGraph where the measurement outcome will be stored.
- `qubit`: The qubit whose measurement outcome is being stored.
- `outcome`: The measurement outcome to be stored.

# Returns
- Nothing. The function modifies the client_meta_graph in-place.

# Examples
```julia
client = Client()
client_meta_graph = MetaGraphs.MetaGraph(graph)
qubit = 1
outcome = 0
store_measurement_outcome!(client, client_meta_graph, qubit, outcome)
```
"""
function store_measurement_outcome!(::Client,client_meta_graph,qubit,outcome)
    set_prop!(client_meta_graph,qubit,:outcome, outcome)
end