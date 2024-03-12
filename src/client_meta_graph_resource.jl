
"""
    generate_random_greedy_color(g, reps)

This function generates a random greedy coloring of a graph. It uses the `random_greedy_color` function from the Graphs package.

# Arguments
- `g`: The graph to be colored.
- `reps`: The number of repetitions for the random greedy coloring algorithm.

# Examples
```julia
g = Graphs.grid_graph((5,5))
reps = 10
generate_random_greedy_color(g, reps)
```
"""
function generate_random_greedy_color(g,reps)
    return Graphs.random_greedy_color(g, reps)
end


"""
    separate_each_color(g::Graphs.Coloring{Int64})

This function extracts from a `Graphs.Coloring{Int64}` and returns a `Vector{Vector{Int64}}`. 
Once a coloring is selected, a vector of integers will result where:
- 1 represents a Dummy vertex
- 2 represents a Trap

# Arguments
- `g::Graphs.Coloring{Int64}`: The graph coloring object.

# Examples
```julia
g = Graphs.grid_graph((5,5))
coloring = Graphs.greedy_color(g)
separate_each_color(coloring)
````
"""
function separate_each_color(g::Graphs.Coloring{Int64})
colouring = map(x-> Int.(g.colors .== x).+1,Base.OneTo(g.num_colors))
return colouring
end


"""
    get_random_coloring(c::Vector{Vector{Int64}})

This function selects a random coloring from a vector of colorings.

# Arguments
- `c::Vector{Vector{Int64}}`: The vector of colorings.

# Examples
```julia
c = [[1, 2, 1], [2, 1, 2], [1, 2, 2]]
get_random_coloring(c)
````
"""
function get_random_coloring(c::Vector{Vector{Int64}})
return rand(c)
end




"""
    MetaGraph(::Client, resource::MBQCResourceState)

This function creates a MetaGraph from a given MBQCResourceState. It extracts the graph from the resource state and wraps it in a MetaGraph.

# Arguments
- `client::Client`: The client object.
- `resource::MBQCResourceState`: The MBQC resource state containing the graph.

# Examples
```julia
client = Client()
resource = MBQCResourceState(graph)
MetaGraph(client, resource)
````
"""
function MetaGraph(::Client,resource::MBQCResourceState)
    g = resource.graph.graph
    return MetaGraphs.MetaGraph(g)
end


"""
    set_vertex_type!(::Union{MBQC,ComputationRound}, resource, mg)

This function sets the vertex type property in a MetaGraph based on the color pattern of the computation round in the resource graph. 
It assigns the `ComputationQubit` type to the vertices according to the color pattern.

# Arguments
- `mbqc::Union{MBQC,ComputationRound}`: The MBQC or ComputationRound object.
- `resource`: The resource containing the graph and its coloring.
- `mg`: The MetaGraph to which the vertex type property will be added.

# Examples
```julia
mbqc = MBQC()
resource = MBQCResourceState(graph)
mg = MetaGraphs.MetaGraph(resource.graph.graph)
set_vertex_type!(mbqc, resource, mg)
```
"""
function set_vertex_type!(::Union{MBQC,ComputationRound},resource,mg)
    color_pattern = Int.(resource.graph.colouring.computation_round)
    qubit_types = [ComputationQubit()]
    vertex_qubit_types_list = [qubit_types[i] for i in color_pattern]
    [set_prop!(mg,i,:vertex_type,vertex_qubit_types_list[i]) for i in vertices(mg)]
    return mg
end


"""
    set_vertex_type!(::TestRound, resource, mg)

This function sets the vertex type property in a MetaGraph based on a random color pattern from the test round in the resource graph. 
It assigns the `DummyQubit` and `TrapQubit` types to the vertices according to the color pattern.

# Arguments
- `test_round::TestRound`: The TestRound object.
- `resource`: The resource containing the graph and its coloring.
- `mg`: The MetaGraph to which the vertex type property will be added.

# Examples
```julia
test_round = TestRound()
resource = MBQCResourceState(graph)
mg = MetaGraphs.MetaGraph(resource.graph.graph)
set_vertex_type!(test_round, resource, mg)
```
"""
function set_vertex_type!(::TestRound,resource,mg)
    g_diff_cols = resource.graph.colouring.test_round
    color_pattern = get_random_coloring(g_diff_cols)
    # Colouring separates each color into a vector of 1s 
    # 2s, the 2s are the traps.
    qubit_types = [DummyQubit(),TrapQubit()] 
    vertex_qubit_types_list = [qubit_types[i] for i in color_pattern]
    [set_prop!(mg,i,:vertex_type,vertex_qubit_types_list[i]) for i in vertices(mg)]
    return mg
end


"""
    set_vertex_type!(::Client, resource, mg)

This function sets the vertex type property in a MetaGraph based on the round type property of the MetaGraph. 
It must be implemented after the round type is implemented.

# Arguments
- `client::Client`: The Client object.
- `resource`: The resource containing the graph and its coloring.
- `mg`: The MetaGraph to which the vertex type property will be added.

# Examples
```julia
client = Client()
resource = MBQCResourceState(graph)
mg = MetaGraphs.MetaGraph(resource.graph.graph)
set_prop!(mg, :round_type, ComputationRound())
set_vertex_type!(client, resource, mg)
```
"""
function set_vertex_type!(::Client,resource,mg)
    round_type = get_prop(mg,:round_type)
    set_vertex_type!(round_type,resource,mg)
    return mg
end


"""
    set_io_qubits_type!(::MBQC, resource, mg)

This function sets the input/output qubits type property in a MetaGraph for MBQC with no blind. 
It assigns the `InputQubits` type to the vertices that are in the input indices and `NoInputQubits` to the rest.

# Arguments
- `client::MBQC`: The MBQC client object.
- `resource`: The resource containing the graph and its coloring.
- `mg`: The MetaGraph to which the vertex io type property will be added.

# Examples
```julia
client = MBQC()
resource = MBQCResourceState(graph)
mg = MetaGraphs.MetaGraph(resource.graph.graph)
set_io_qubits_type!(client, resource, mg)
```
"""
function set_io_qubits_type!(::MBQC,resource,mg)
    idx_vec = get_input_indices(resource)
    val_vec = get_input_values(resource)
    for v in get_vertex_iterator(resource)
        in_bool = v ∈ idx_vec
        in_bool ? set_props!(mg,v,Dict(:vertex_io_type => InputQubits(),:classic_input => val_vec[v])) : 
            set_prop!(mg,v,:vertex_io_type,NoInputQubits())
    end
end


"""
    set_io_qubits_type!(::ComputationRound, resource, mg)

In Computation round, there are sometimes input values for qubits. When this happens, this function will allocate space for them in the property graph. 
It assigns the `InputQubits` type to the vertices that are in the input indices and `NoInputQubits` to the rest.

# Arguments
- `round::ComputationRound`: The ComputationRound object.
- `resource`: The resource containing the graph and its coloring.
- `mg`: The MetaGraph to which the vertex io type property will be added.

# Examples
```julia
round = ComputationRound()
resource = MBQCResourceState(graph)
mg = MetaGraphs.MetaGraph(resource.graph.graph)
set_io_qubits_type!(round, resource, mg)
```
"""
function set_io_qubits_type!(::ComputationRound,resource,mg)
    idx_vec = get_input_indices(resource)
    val_vec = get_input_values(resource)
    for v in get_vertex_iterator(resource)
        in_bool = v ∈ idx_vec
        in_bool ? set_props!(mg,v,Dict(:vertex_io_type => InputQubits(),:classic_input => val_vec[v])) : 
            set_prop!(mg,v,:vertex_io_type,NoInputQubits())
    end
end


"""
    set_io_qubits_type!(::TestRound, resource, mg)

In Test rounds there is no classical input, but this holder function allows for unilateral call, regardless of round. 
It assigns the `NoInputQubits` type to all the vertices.

# Arguments
- `round::TestRound`: The TestRound object.
- `resource`: The resource containing the graph and its coloring.
- `mg`: The MetaGraph to which the vertex io type property will be added.

# Examples
```julia
round = TestRound()
resource = MBQCResourceState(graph)
mg = MetaGraphs.MetaGraph(resource.graph.graph)
set_io_qubits_type!(round, resource, mg)
```
"""
function set_io_qubits_type!(::TestRound,resource,mg)
    for v in get_vertex_iterator(resource)
        set_prop!(mg,v,:vertex_io_type,NoInputQubits())
    end
end


"""
    set_io_qubits_type!(::Client, resource, mg)

This function sets the input/output qubits type property in a MetaGraph based on the round type property of the MetaGraph. 

# Arguments
- `client::Client`: The Client object.
- `resource`: The resource containing the graph and its coloring.
- `mg`: The MetaGraph to which the vertex io type property will be added.

# Examples
```julia
client = Client()
resource = MBQCResourceState(graph)
mg = MetaGraphs.MetaGraph(resource.graph.graph)
set_prop!(mg, :round_type, ComputationRound())
set_io_qubits_type!(client, resource, mg)
```
"""
function set_io_qubits_type!(::Client,resource,mg)
    round_type = get_prop(mg,:round_type)
    set_io_qubits_type!(round_type,resource,mg)
end


"""
    init_qubit_meta_graph!(::Client, mbqc::MBQC, resource::MBQCResourceState, mg)

This function initializes the qubit meta graph for a client in the MBQC model. 
It sets the secret angle and initial qubit properties for each vertex in the meta graph.

# Arguments
- `client::Client`: The Client object.
- `mbqc::MBQC`: The MBQC object.
- `resource::MBQCResourceState`: The resource containing the graph and its coloring.
- `mg`: The MetaGraph to which the properties will be added.

# Examples
```julia
client = Client()
mbqc = MBQC()
resource = MBQCResourceState(graph)
mg = MetaGraphs.MetaGraph(resource.graph.graph)
init_qubit_meta_graph!(client, mbqc, resource, mg)
```
"""
function init_qubit_meta_graph!(::Client,::MBQC,resource::MBQCResourceState,mg)
    verts = get_vertex_iterator(resource)
    for v in verts
        ϕ = get_angle(resource,SecretAngles(),v) 
        set_prop!(mg,v,:secret_angle,ϕ)
        set_prop!(mg,v,:init_qubit,ϕ)
    end
    return mg
end





"""
    init_qubit(::TrapQubit)::Float64

This function is used to initialize the qubit in the meta graph. 
The state is not given, but the angle for the plus phase state for a trap qubit is returned.

# Arguments
- `trap::TrapQubit`: The TrapQubit object.

# Returns
- A Float64 representing the angle for the plus phase state for a trap qubit.

# Examples
```julia
trap = TrapQubit()
angle = init_qubit(trap)
```
"""
function init_qubit(::TrapQubit)::Float64
    draw_θᵥ()
end


"""
    init_qubit(::DummyQubit)::Int64

This function is used to initialize the qubit in the meta graph. 
The state is not given, but the bit for the initial state of the dummy qubit is returned.

# Arguments
- `dummy::DummyQubit`: The DummyQubit object.

# Returns
- An Int64 representing the bit for the initial state of the dummy qubit.

# Examples
```julia
dummy = DummyQubit()
bit = init_qubit(dummy)
````
"""
function init_qubit(::DummyQubit)::Int64
    draw_dᵥ()
end


"""
    init_qubit_meta_graph!(::Client, ::ComputationRound, resource::MBQCResourceState, mg)

This function initializes the qubit meta graph for a client in the MBQC model during a computation round. 
It sets the secret angle and initial qubit properties for each vertex in the meta graph.

# Arguments
- `::Client`: The Client object.
- `::ComputationRound`: The ComputationRound object.
- `resource::MBQCResourceState`: The resource containing the graph and its coloring.
- `mg`: The MetaGraph to which the properties will be added.

# Examples
```julia
client = Client()
round = ComputationRound()
resource = MBQCResourceState(graph)
mg = MetaGraphs.MetaGraph(resource.graph.graph)
init_qubit_meta_graph!(client, round, resource, mg)
```
"""
function init_qubit_meta_graph!(::Client,::ComputationRound,resource::MBQCResourceState,mg)
    verts = get_vertex_iterator(resource)
    for v in verts
        θ = draw_θᵥ()
        ϕ = get_angle(resource,SecretAngles(),v) 
        set_prop!(mg,v,:secret_angle,ϕ)
        set_prop!(mg,v,:init_qubit,θ)
    end
    return mg
end


"""
    init_qubit_meta_graph!(::Client, ::TestRound, resource::MBQCResourceState, mg)

This function initializes the qubit meta graph for a client in the MBQC model during a test round. 
It sets the initial qubit property for each vertex in the meta graph based on the vertex type.

# Arguments
- `::Client`: The Client object.
- `::TestRound`: The TestRound object.
- `resource::MBQCResourceState`: The resource containing the graph and its coloring.
- `mg`: The MetaGraph to which the properties will be added.

# Examples
```julia
client = Client()
round = TestRound()
resource = MBQCResourceState(graph)
mg = MetaGraphs.MetaGraph(resource.graph.graph)
init_qubit_meta_graph!(client, round, resource, mg)
```
"""
function init_qubit_meta_graph!(::Client,::TestRound,resource::MBQCResourceState,mg)
    verts = get_vertex_iterator(resource)    
    for v in verts
        qubit_type = get_prop(mg,v,:vertex_type) 
        init_qubit_value = init_qubit(qubit_type)
        set_prop!(mg,v,:init_qubit,init_qubit_value)
    end
    return mg
end


"""
    init_qubit_meta_graph!(::Client, resource, mg)

This function initializes the qubit meta graph for a client in the MBQC model. 
It retrieves the round type from the meta graph and then calls the appropriate 
`init_qubit_meta_graph!` function based on the round type.

# Arguments
- `::Client`: The Client object.
- `resource`: The resource containing the graph and its coloring.
- `mg`: The MetaGraph to which the properties will be added.

# Examples
```julia
client = Client()
resource = MBQCResourceState(graph)
mg = MetaGraphs.MetaGraph(resource.graph.graph)
set_prop!(mg, :round_type, ComputationRound())
init_qubit_meta_graph!(client, resource, mg)
```
"""
function init_qubit_meta_graph!(::Client,resource,mg)
    round_type = get_prop(mg,:round_type)
    init_qubit_meta_graph!(Client(),round_type,resource,mg)
end


"""
    convert_flow_type_symbol(::Client, flow_type::Union{ForwardFlow,BackwardFlow})

This function converts a flow type (either ForwardFlow or BackwardFlow) into a symbol. 
The conversion process involves converting the flow type to a string, removing parentheses, 
adding an underscore before "Flow", converting to lowercase, and finally converting to a symbol.

# Arguments
- `::Client`: The Client object.
- `flow_type::Union{ForwardFlow,BackwardFlow}`: The flow type to be converted.

# Returns
- A Symbol representing the flow type.

# Examples
```julia
client = Client()
flow_type = ForwardFlow()
flow_sym = convert_flow_type_symbol(client, flow_type)
```
"""
function convert_flow_type_symbol(::Client,flow_type::Union{ForwardFlow,BackwardFlow})
    flow_sym = @chain flow_type begin
        string(_)
        replace(_,"()"=>"")
        replace(_,"Flow"=>"_Flow")
        lowercase(_)
        Symbol(_)    
    end
    return flow_sym
end


"""
    compute_backward_flow(graph, forward_flow, vertex)

This function computes the backward flow of a given vertex in a graph. 
It first finds the neighbors of the vertex and checks if the vertex is in the forward flow of any of its neighbors. 
If it is not, the function returns 0. 
If it is, the function finds the index of the vertex in the forward flow of its neighbors. 
If the vertex is not in the flow of the neighbors, an error is thrown. 
If there is more than one past vertex found, an error is thrown. 
Otherwise, the function returns the first past vertex.

# Arguments
- `graph`: The graph.
- `forward_flow`: The forward flow function.
- `vertex`: The vertex for which to compute the backward flow.

# Returns
- The first past vertex if it exists, 0 otherwise.

# Examples
```julia
graph = Graph(5)
forward_flow = (n -> n + 1)
vertex = 3
backward_flow_vertex = compute_backward_flow(graph, forward_flow, vertex)
```
"""
function compute_backward_flow(graph,forward_flow,vertex)
    neighs = neighbors(graph,vertex)
    fflow_neighs = [forward_flow(n) for n in neighs]
    !any(vertex .∈ fflow_neighs) && return 0 
    index_neigh = findall(x->x==vertex,fflow_neighs)
    length(index_neigh) == 0 && error("The inputted vertex is not in the flow of the neighbours.")
    previous_vertex = neighs[index_neigh]
    length(previous_vertex) > 1 && error("There is more than one past vertex found")
    previous_vertex[1]
end


"""
    add_flow_vertex!(::Client, mg, resource::MBQCResourceState, flow_type::Union{ForwardFlow,BackwardFlow})

This function adds a flow vertex to the meta graph for a client in the MBQC model. 
It first converts the flow type to a symbol, then iterates over each vertex in the resource. 
For each vertex, it gets the verified flow output and sets this as a property in the meta graph.

# Arguments
- `::Client`: The Client object.
- `mg`: The MetaGraph to which the properties will be added.
- `resource::MBQCResourceState`: The resource containing the graph and its coloring.
- `flow_type::Union{ForwardFlow,BackwardFlow}`: The flow type to be added.

# Returns
- The updated MetaGraph.

# Examples
```julia
client = Client()
resource = MBQCResourceState(graph)
mg = MetaGraphs.MetaGraph(resource.graph.graph)
flow_type = ForwardFlow()
add_flow_vertex!(client, mg, resource, flow_type)
```
"""
function add_flow_vertex!(
    ::Client,
    mg,
    resource::MBQCResourceState,
    flow_type::Union{ForwardFlow,BackwardFlow})
    flow_sym = convert_flow_type_symbol(Client(),flow_type)
        
    verts = get_vertex_iterator(resource)
    for v in verts
        fv = get_verified_flow_output(flow_type,resource,v)
        set_prop!(mg,v,flow_sym,fv)
    end
    return mg
end



"""
    add_flow_vertex!(::Client, mg, resource::MBQCResourceState)

This function adds both forward and backward flow vertices to the meta graph for a client in the MBQC model. 
It calls the `add_flow_vertex!` function twice, once with `ForwardFlow` and once with `BackwardFlow`.

# Arguments
- `::Client`: The Client object.
- `mg`: The MetaGraph to which the properties will be added.
- `resource::MBQCResourceState`: The resource containing the graph and its coloring.

# Returns
- The updated MetaGraph.

# Examples
```julia
client = Client()
resource = MBQCResourceState(graph)
mg = MetaGraphs.MetaGraph(resource.graph.graph)
add_flow_vertex!(client, mg, resource)
```
"""
function add_flow_vertex!(::Client,mg,resource::MBQCResourceState)
    add_flow_vertex!(Client(),mg,resource,ForwardFlow())
    add_flow_vertex!(Client(),mg,resource,BackwardFlow())
end


"""
    add_correction_vertices!(::Client, mg, resource::MBQCResourceState)

This function adds correction vertices to the meta graph for a client in the MBQC model. 
It iterates over each vertex in the resource, gets the correction vertices for each, 
and sets these as properties in the meta graph.

# Arguments
- `::Client`: The Client object.
- `mg`: The MetaGraph to which the properties will be added.
- `resource::MBQCResourceState`: The resource containing the graph and its coloring.

# Returns
- The updated MetaGraph.

# Examples
```julia
client = Client()
resource = MBQCResourceState(graph)
mg = MetaGraphs.MetaGraph(resource.graph.graph)
add_correction_vertices!(client, mg, resource)
```
"""
function add_correction_vertices!(::Client,mg,resource::MBQCResourceState)
    verts = get_vertex_iterator(resource)
    for v in verts
        cor = get_correction_vertices(resource,v)
        set_props!(mg,v,Dict(:X_correction => cor[:X],:Z_correction => cor[:Z]))
    end
    return mg
end


"""
    init_measurement_outcomes!(::Client, mg, resource::MBQCResourceState)

This function initializes the measurement outcomes in the meta graph for a client in the MBQC model. 
It iterates over each vertex in the resource and sets the `:outcome` property of each vertex in the meta graph to `Int64`.

# Arguments
- `::Client`: The Client object.
- `mg`: The MetaGraph to which the properties will be added.
- `resource::MBQCResourceState`: The resource containing the graph and its coloring.

# Returns
- The updated MetaGraph.

# Examples
```julia
client = Client()
resource = MBQCResourceState(graph)
mg = MetaGraphs.MetaGraph(resource.graph.graph)
init_measurement_outcomes!(client, mg, resource)
```
"""
function init_measurement_outcomes!(::Client,mg,resource::MBQCResourceState)
    verts = get_vertex_iterator(resource)
    for v in verts
        set_prop!(mg,v,:outcome,Int64)
    end
    return mg
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

#=
function initialise_quantum_state_meta_graph!(
    ::Client,
    state_type::StateVector,
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
=#


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
    add_round_type!(::Client, mg, round_type)

This function adds a round type to the meta graph for a client in the MBQC model. 
It sets the `:round_type` property of the meta graph to the specified round type.

# Arguments
- `::Client`: The Client object.
- `mg`: The MetaGraph to which the property will be added.
- `round_type`: The round type to be added to the meta graph.

# Returns
- The updated MetaGraph.

# Examples
```julia
client = Client()
mg = MetaGraphs.MetaGraph(graph)
round_type = "round1"
add_round_type!(client, mg, round_type)
```
"""
function add_round_type!(::Client,mg,round_type)
    set_prop!(mg,:round_type,round_type) # Set round to graph
    mg
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