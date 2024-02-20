##################################################################
# Filename  : struct_utility_functions.jl
# Author    : Jonathan Miller
# Date      : 2023-07-07
# Aim       : aim_script
#           : Write function to assist in the ut
#           :
##################################################################


"""
    assert_comment(condition, message)

Asserts that a given `condition` is true. If the `condition` is false, the function throws an AssertionError with the provided `message`.

# Arguments
- `condition`: The condition to be checked.
- `message`: The message to be displayed if the assertion fails.

# Examples
```julia
assert_comment(1 == 1, "Numbers are not equal") # Does not throw an error
assert_comment(1 == 2, "Numbers are not equal") # Throws an AssertionError
```
"""
function assert_comment(condition,message)
    @assert condition message
end




"""
    throw_error(::DummyQubitZeroOneInitialisationError)

Throws an error message when the input qubit value is not an integer 0 or 1.

# Examples
```julia
throw_error(DummyQubitZeroOneInitialisationError()) # Throws an error with a specific message
```
"""
function throw_error(::DummyQubitZeroOneInitialisationError)
    @error "Input qubit value is either a 1 or a 0, both integers, seeing this error means neither 0 or 1 integer was passed."
end



"""
    throw_error(::QubitFloatPhaseInitialisationError)

Throws an error message when the input qubit value is not a Float64 for a plus state with a phase.

# Examples
```julia
throw_error(QubitFloatPhaseInitialisationError()) # Throws an error with a specific message
```
"""
function throw_error(::QubitFloatPhaseInitialisationError)
    @error "Input qubit value is meant to be a Float64 for a plus state with a phase, seeing this error means the input value was not a Float64."
end



"""
    throw_warning(::FunctionNotMeantToBeUsed)

Throws a warning message when a function that is not meant to be used anymore is called.

# Examples
```julia
throw_warning(FunctionNotMeantToBeUsed()) # Throws a warning with a specific message
```
"""
function throw_warning(::FunctionNotMeantToBeUsed)
    @warn "This function is not meant to be used anymore, this is a generic warning message. Find out what function is throwing this issue"
end





"""
    get_vector_graph_colors(graph; reps=100)

Generates a vector of graph colors. It first generates a random greedy color for the graph (repeated `reps` times), then separates each color.

# Arguments
- `graph`: The graph to be colored.
- `reps`: The number of repetitions for generating the random greedy color (default is 100).

# Examples
```julia
get_vector_graph_colors(graph) # Returns a vector of graph colors
```
"""
function get_vector_graph_colors(graph;reps=100)
    g_cols = generate_random_greedy_color(graph,reps)        
    separate_each_color(g_cols)
end





"""
    create_graph_resource(p::NamedTuple)::MBQCResourceState

Creates an `MBQCResourceState` from a NamedTuple `p`. The NamedTuple should contain the following keys: `input_indices`, `input_values`, `output_indices`, `computation_colours`, `test_colours`, `graph`, `forward_flow`, `backward_flow`, and `secret_angles`.

# Arguments
- `p`: A NamedTuple containing the necessary parameters to create an `MBQCResourceState`.

# Examples
```julia
params = (input_indices = ..., input_values = ..., output_indices = ..., computation_colours = ..., test_colours = ..., graph = ..., forward_flow = ..., backward_flow = ..., secret_angles = ...)
resource = create_graph_resource(params)
```
"""
function create_graph_resource(p::NamedTuple)::MBQCResourceState
    input = MBQCInput(p[:input_indices],p[:input_values]) 
    output = MBQCOutput(p[:output_indices])
    colors = MBQCColouringSet(p[:computation_colours],p[:test_colours])
    mbqc_graph = MBQCGraph(p[:graph],colors,input,output)
    mbqc_flow = MBQCFlow(p[:forward_flow],p[:backward_flow])
    mbqc_angles = MBQCAngles(p[:secret_angles])
    resource = MBQCResourceState(mbqc_graph,mbqc_flow,mbqc_angles)
    return resource
end


"""
    get_number_qubits(resource::MBQCResourceState)

Retrieve the number of qubits in an MBQC resource state.

# Arguments
- `resource::MBQCResourceState`: An MBQC resource state containing the graph representation of the resource.

# Returns
The number of qubits in the resource state.

# Examples
```julia
# Create an MBQC resource state
graph = MBQCGraph(...)
flow = MBQCFlow(...)
angles = MBQCAngles(...)
resource = MBQCResourceState(graph, flow, angles)

# Get the number of qubits
num_qubits = get_number_qubits(resource)
```
"""
function get_number_vertices(resource::MBQCResourceState)
    return resource.graph.graph |> nv
end



"""
    get_edge_iterator(resource::MBQCResourceState)

Retrieve an iterator over the edges in an MBQC resource state.

# Arguments
- `resource::MBQCResourceState`: An MBQC resource state containing the graph representation of the resource.

# Returns
An iterator over the edges of the resource state's graph.

# Examples
```julia
# Create an MBQC resource state
graph = MBQCGraph(...)
flow = MBQCFlow(...)
angles = MBQCAngles(...)
resource = MBQCResourceState(graph, flow, angles)

# Get the edge iterator
edge_iterator = get_edge_iterator(resource)
```
"""
function get_edge_iterator(resource::MBQCResourceState)
    return resource.graph.graph |> edges
end



"""
    get_vertex_iterator(resource::MBQCResourceState)

Retrieve an iterator over the vertices in an MBQC resource state.

# Arguments
- `resource::MBQCResourceState`: An MBQC resource state containing the graph representation of the resource.

# Returns
An iterator over the vertices of the resource state's graph.

# Examples
```julia
# Create an MBQC resource state
graph = MBQCGraph(...)
flow = MBQCFlow(...)
angles = MBQCAngles(...)
resource = MBQCResourceState(graph, flow, angles)

# Get the vertex iterator
vertex_iterator = get_vertex_iterator(resource)
```
"""
function get_vertex_iterator(resource::MBQCResourceState)
    return resource.graph.graph |> vertices
end




"""
get_vertex_neighbours(resource::MBQCResourceState, vertex)

Retrieve the neighbors of a given vertex in an MBQC resource state.

# Arguments
- `resource::MBQCResourceState`: An MBQC resource state containing the graph representation of the resource.
- `vertex`: The vertex for which to retrieve the neighbors.

# Returns
An array of vertices representing the neighbors of the specified vertex.

# Examples
```julia
# Create an MBQC resource state
graph = MBQCGraph(...)
flow = MBQCFlow(...)
angles = MBQCAngles(...)
resource = MBQCResourceState(graph, flow, angles)

# Get the neighbors of a vertex
vertex = 1
neighbors = get_vertex_neighbours(resource, vertex)
```
"""
function get_vertex_neighbours(resource::MBQCResourceState, vertex)
    g = resource.graph.graph
    return all_neighbors(g, vertex)
end


"""
    get_input_indices(resource::MBQCResourceState)

Returns the input indices from a given `MBQCResourceState`.

# Arguments
- `resource`: An `MBQCResourceState` from which to extract the input indices.

# Examples
```julia
indices = get_input_indices(resource) # Returns the input indices of the resource
```
"""
function get_input_indices(resource::MBQCResourceState)
    return resource.graph.input.indices
end


"""
    get_input_values(resource::MBQCResourceState)

Returns the input values from a given `MBQCResourceState`.

# Arguments
- `resource`: An `MBQCResourceState` from which to extract the input values.

# Examples
```julia
values = get_input_values(resource) # Returns the input values of the resource
```
"""
function get_input_values(resource::MBQCResourceState)
    return resource.graph.input.values
end





"""
    get_input_value(resource::MBQCResourceState, iter)

Returns the input value at the `iter`-th index from a given `MBQCResourceState`. If `iter` is greater than the length of the input indices, the function returns `nothing`.

# Arguments
- `resource`: An `MBQCResourceState` from which to extract the input value.
- `iter`: The index at which to extract the input value.

# Examples
```julia
value = get_input_value(resource, 1) # Returns the input value at the first index of the resource
```
"""
function get_input_value(resource::MBQCResourceState,iter)
    input_values = get_input_values(resource)
    input_indices = get_input_indices(resource)
    len_input_indices = length(input_indices)
    iter > len_input_indices && return nothing
    return input_values[input_indices[iter]]
end





"""
    get_angles(resource::MBQCResourceState, ::SecretAngles)

Returns the secret angles from a given `MBQCResourceState`.

# Arguments
- `resource`: An `MBQCResourceState` from which to extract the secret angles.

# Examples
```julia
angles = get_angles(resource, SecretAngles()) # Returns the secret angles of the resource
```
"""
function get_angles(resource::MBQCResourceState,::SecretAngles)
    return resource.angles.secret_angles
end


"""
    get_angle(resource::MBQCResourceState, AngleType, vertex)

Returns the angle of a specific vertex from a given `MBQCResourceState` and `AngleType`.

# Arguments
- `resource`: An `MBQCResourceState` from which to extract the angle.
- `AngleType`: The type of angle to be extracted.
- `vertex`: The vertex for which to extract the angle.

# Examples
```julia
angle = get_angle(resource, SecretAngles(), vertex) # Returns the angle of the specified vertex
```
"""
function get_angle(resource::MBQCResourceState,AngleType,vertex)
    return get_angles(resource,AngleType)[vertex]
end




"""
    get_graph(resource::MBQCResourceState)

Get the graph associated with the given `MBQCResourceState`.

# Arguments
- `resource::MBQCResourceState`: The resource state object.

# Returns
- The graph associated with the resource state.

# Examples
```julia
graph = get_graph(resource) # Returns the graph associated with the resource
```
"""
function get_graph(resource::MBQCResourceState)
    return resource.graph.graph
end




"""
    get_flow(flow_type::BackwardFlow, resource::MBQCResourceState)

Get the backward flow of a given resource.

# Arguments
- `flow_type::BackwardFlow`: The type of flow to retrieve.
- `resource::MBQCResourceState`: The resource state to retrieve the flow from.

# Returns
The backward flow of the resource.

# Examples
```julia
"""
function get_flow(::BackwardFlow,resource::MBQCResourceState)
    return resource.flow.backward_flow
end





"""
    get_flow(flow_type, resource)

Get the flow of a given resource.

# Arguments
- `flow_type`: The type of flow (e.g., `ForwardFlow`, `BackwardFlow`).
- `resource`: The resource state.

# Returns
The flow of the resource.

# Examples
```julia
"""
function get_flow(::ForwardFlow,resource::MBQCResourceState)
    return resource.flow.forward_flow
end






"""
    get_verified_flow_output(T, resource, vertex)

Get the verified flow output for a given vertex in a MBQC resource state.

# Arguments
- `T`: The type of flow, which must be either `ForwardFlow` or `BackwardFlow`.
- `resource`: The MBQC resource state.
- `vertex`: The vertex for which to get the verified flow output.

# Returns
- If the flow output is a valid vertex in the neighborhood of the given vertex, it returns the verified flow output.
- If the flow output is `Nothing`, it returns `nothing`.
- If the flow type is neither `ForwardFlow` nor `BackwardFlow`, it throws an error.

# Examples
```julia
T = ForwardFlow()
resource = MBQCResourceState(...)
vertex = 1
output = get_verified_flow_output(T, resource, vertex) # Returns the verified flow output for the given vertex
```
"""
function get_verified_flow_output(T,resource::MBQCResourceState,vertex::Int64)
    flow = get_flow(T,resource)
    neighs = get_vertex_neighbours(resource,vertex)
    if T isa ForwardFlow
        new_vertex = flow(vertex)
        if issubset(new_vertex,neighs)
            new_vertex_in_intersection = 
                intersect(neighs,new_vertex)
            @assert length(new_vertex_in_intersection)==1 "Intersection of neighbourhood of vertex and forward vertex should be 1, it is $(lenth(new_vertex_in_intersection)), figure out problem."
            return new_vertex_in_intersection[1]
        elseif new_vertex isa Nothing
            return nothing
        else 
            return nothing
        end
    elseif T isa BackwardFlow
        new_vertex = flow(vertex)
        if issubset(new_vertex,neighs)
            new_vertex_in_intersection = 
                intersect(neighs,new_vertex)
            @assert length(new_vertex_in_intersection)==1 "Intersection of neighbourhood of vertex and forward vertex should be 1, it is $(lenth(new_vertex_in_intersection)), figure out problem."
            return new_vertex_in_intersection[1]
        elseif new_vertex isa Nothing
            return nothing
        else
            return nothing
        end
    else
        @error "Type for flow must be ForwardFlow or BackwardFlow, it is $(T), fix"
    end
end




"""
    get_verified_flow(T, resource::MBQCResourceState)

Create a function that returns the verified flow output for a given vertex.

# Arguments
- `T`: The flow graph.
- `resource`: The MBQC resource state.

# Returns
A function `f` that takes a vertex as input and returns the verified flow output.

# Example
```julia
T = ForwardFlow()
resource = MBQCResourceState(...)
f = get_verified_flow(T, resource) # Returns a function that takes a vertex as input and returns the verified flow output
```
"""
function get_verified_flow(T,resource::MBQCResourceState)
    f(vertex) = get_verified_flow_output(T,resource,vertex)
    return f
end



"""
    get_input_size(resource::MBQCResourceState)::Int64

Get the size of the input for the given `MBQCResourceState`.

# Arguments
- `resource::MBQCResourceState`: The MBQC resource state.

# Returns
- `Int64`: The size of the input.

# Examples
```julia
size = get_input_size(resource) # Returns the size of the input
```
"""
function get_input_size(resource::MBQCResourceState)::Int64
    return length(resource.graph.input.indices)
end




"""
    get_output_size(resource::MBQCResourceState)::Int64

Get the size of the output for a given `MBQCResourceState`.

# Arguments
- `resource::MBQCResourceState`: The resource state for which to get the output size.

# Returns
- `Int64`: The size of the output.

# Examples
```julia
size = get_output_size(resource) # Returns the size of the output
```
"""
function get_output_size(resource::MBQCResourceState)::Int64
    return length(resource.graph.output.indices)
end



"""
    get_minimum_vertex_index_flow(resource::MBQCResourceState)

Get the minimum vertex index flow for a given `MBQCResourceState`.

# Arguments
- `resource::MBQCResourceState`: The MBQC resource state.

# Returns
- `Int64`: The minimum vertex index flow.

# Example
```julia
min_vertex = get_minimum_vertex_index_flow(resource) # Returns the minimum vertex index flow
```
"""
function get_minimum_vertex_index_flow(resource::MBQCResourceState)::Int64
    min_num_vertices_to_skip = get_input_size(resource)
    # Return next vertex index after size of input
    return min_num_vertices_to_skip +=1
end




"""
    get_size_measurement_vector(resource::MBQCResourceState)::Int64

Get the size of the measurement vector for a given `MBQCResourceState`.

# Arguments
- `resource::MBQCResourceState`: The resource state for which to calculate the measurement vector size.

# Returns
- `Int64`: The size of the measurement vector.

# Examples
```julia
size = get_size_measurement_vector(resource) # Returns the size of the measurement vector
```
"""
function get_size_measurement_vector(resource::MBQCResourceState)::Int64
    min_num_vertices_to_stop_before = get_output_size(resource)
    num_vertices = get_number_vertices(resource)
    iszero(min_num_vertices_to_stop_before) && return num_vertices
    return num_vertices - min_num_vertices_to_stop_before
end





"""
    get_measurement_outcome_iterator(resource::MBQCResourceState)

Returns an iterator that generates indices for measuring the vertices of a MBQC resource state.

# Arguments
- `resource::MBQCResourceState`: The MBQC resource state.

# Returns
An iterator that generates indices for measuring the vertices of the resource state.

# Example
```julia
iterator = get_measurement_outcome_iterator(resource) # Returns an iterator that generates indices for measuring the vertices of the resource
```
"""
function get_measurement_outcome_iterator(resource::MBQCResourceState)::Base.OneTo{Int64}
    total_vertices_to_measure = get_size_measurement_vector(resource)
    total_vertices_to_measure -=1
    return Base.OneTo(total_vertices_to_measure)
end



"""
    get_stop_start_vertices(resource::MBQCResourceState)

Get the start and stop vertices for a given `MBQCResourceState`.

# Arguments
- `resource::MBQCResourceState`: The MBQC resource state.

# Returns
- `Tuple{Int64, Int64}`: A tuple containing the start and stop vertices.

# Example
```julia
start, stop = get_stop_start_vertices(resource) # Returns the start and stop vertices
```
"""
function get_stop_start_vertices(resource::MBQCResourceState)::Tuple{Int64,Int64}
    start_vertex = get_minimum_vertex_index_flow(resource)
    stop_vertex = get_size_measurement_vector(resource)
    return (start_vertex,stop_vertex) 
end



"""
    init_outcomes_vector(resource::MBQCResourceState)

Initialize the outcomes vector for a given MBQC resource state.

# Arguments
- `resource::MBQCResourceState`: The MBQC resource state.

# Returns
- `outcomes_vec::Vector`: The initialized outcomes vector.

# Example
```julia
outcomes_vec = init_outcomes_vector(resource) # Returns the initialized outcomes vector
```
"""
function init_outcomes_vector(resource::MBQCResourceState)::Vector
    max_index_to_be_measured = get_size_measurement_vector(resource)    
    input_values = get_input_values(resource)
    input_indices = get_input_indices(resource) 
    outcomes_vec = Vector(undef, max_index_to_be_measured)
    for i in input_indices
        outcomes_vec[i] = input_values[i]
    end
    return outcomes_vec
end




"""
    is_vertex_in_graph(resource::MBQCResourceState, vertex::Int64)

Check if a vertex is present in a graph.

# Arguments
- `resource::MBQCResourceState`: The MBQC resource state.
- `vertex::Int64`: The vertex to check.

# Returns
- `Bool`: `true` if the vertex is present in the graph, `false` otherwise.

# Example
```julia
is_vertex_in_graph(resource, vertex) # Returns true if the vertex is present in the graph, false otherwise
```
"""
function is_vertex_in_graph(resource::MBQCResourceState, vertex::Int64)
    verts = get_vertex_iterator(resource)
    vertex ∈ verts
end





"""
    is_vertex_in_graph(resource::MBQCResourceState, novertex::Nothing)

Check if a vertex is present in the graph.

# Arguments
- `resource::MBQCResourceState`: The MBQC resource state.
- `novertex::Nothing`: The vertex to check.

# Returns
- `true` if the vertex is present in the graph, `false` otherwise.

# Example
```julia
is_vertex_in_graph(resource, novertex) # Returns true if the vertex is present in the graph, false otherwise
```
"""
function is_vertex_in_graph(resource::MBQCResourceState, novertex::Nothing)
    return false
end





"""
    assert_flow(flow_type, resource, vertex)

Check the validity of a flow in a resource graph.

Arguments:
- `flow_type`: The type of flow to be checked.
- `resource`: The resource state representing the graph.
- `vertex`: The vertex to be checked.

This function performs several assertions to verify the flow:
- Checks if the flow of the given vertex is in the vertex set of the graph.
- Checks if the given vertex is in the neighborhood of the flow of the vertex.
- Checks if the given vertex is less than or equal to the flow of the vertex.
- Checks if all vertices in the neighborhood of the flow of the vertex are greater than or equal to the vertex.

# Examples
```julia
assert_flow(ForwardFlow(), resource, vertex) # Checks the validity of the forward flow
```
"""
function assert_flow(::ForwardFlow, resource::MBQCResourceState, vertex::Int64)
    T = ForwardFlow()
    flow = get_flow(T,resource)
    new_vertex = flow(vertex)    
    is_in_graph = is_vertex_in_graph(resource,new_vertex)
    assert_comment(is_in_graph, "f(vertex), $(new_vertex), is not in the vertex set, $(verts |> collect).")
    new_neighbours = get_vertex_neighbours(resource, new_vertex)
    assert_comment(vertex ∈ new_neighbours, "Vertex, $(vertex), is not in the nieghbourhood, $(new_neighbours), of the f(vertex), $(new_vertex), Flow C1")
    assert_comment(vertex ≤ new_vertex, "Vertex, $(vertex), is not less than or equal to f(vertex), $(new_vertex), Flow C2" )
    assert_comment(all(vertex .≤ new_neighbours), "Vertex, $(vertex), is not less than or equal to the nieghbourhood, $(new_neighbours), of the f(vertex), $(new_vertex), Flow C3")
end



"""
    assert_flow(::BackwardFlow, resource::MBQCResourceState, vertex::Int64)

Asserts the properties of a backward flow in a MBQC resource state.

Arguments:
- `::BackwardFlow`: The backward flow type.
- `resource::MBQCResourceState`: The MBQC resource state.
- `vertex::Int64`: The vertex to be checked.

The function checks the following properties of the backward flow:
1. The flow of the given vertex is in the vertex set of the resource state.
2. The given vertex is in the neighborhood of the flow of the given vertex.
3. The given vertex is less than or equal to all vertices in the neighborhood of the flow of the given vertex.

Throws an error with an appropriate message if any of the properties are violated.

# Examples
```julia
assert_flow(BackwardFlow(), resource, vertex) # Asserts the properties of the backward flow
```
"""
function assert_flow(::BackwardFlow,resource::MBQCResourceState,vertex::Int64)
    T = BackwardFlow()
    flow = get_flow(T,resource)
    new_vertex = flow(vertex)    
    is_in_graph = is_vertex_in_graph(resource,new_vertex)
    assert_comment(is_in_graph, "f(vertex), $(new_vertex), is not in the vertex set, $(verts |> collect).")
    new_neighbours = get_vertex_neighbours(resource, new_vertex)
    assert_comment(vertex ∈ new_neighbours, "Vertex, $(vertex), is not in the nieghbourhood, $(new_neighbours), of the f(vertex), $(new_vertex), Flow C1")
    assert_comment(vertex ≥ new_vertex, "Vertex, $(vertex), is not less than or equal to f(vertex), $(new_vertex), Flow C2")
    assert_comment(all(vertex .≥ new_neighbours), "Vertex, $(vertex), is not less than or equal to the nieghbourhood, $(new_neighbours), of the f(vertex), $(new_vertex), Flow C3")
end



"""
    get_corrections_one_neighbourhood_two_vertex_graph(resource::MBQCResourceState, vertex::Int64)

This function calculates the corrections needed for a two-vertex graph in a one-neighbourhood MBQC resource state.

# Arguments
- `resource::MBQCResourceState`: The MBQC resource state.
- `vertex::Int64`: The vertex in the graph.

# Returns
- `corrections`: A tuple `(X=x_correction_vertex, Z=z_correction_vertices)` representing the corrections needed.

# Errors
- Throws an error if the vertex is not in the graph.
- Throws an error if the size of the graph is not 2.
- Throws an error if the size of the vertex neighbour set is not 1.
- Throws an error if neither the forward flow nor the backward flow of the vertex is in the graph.

# Examples
```julia
corrections = get_corrections_one_neighbourhood_two_vertex_graph(resource, vertex) # Returns the corrections needed for the given vertex
```
"""
function get_corrections_one_neighbourhood_two_vertex_graph(resource::MBQCResourceState,vertex::Int64)
    assert_comment(is_vertex_in_graph(resource,vertex), "Vertex: $(vertex), is not in the graph, find a different function")
    g_size = get_number_vertices(resource)
    assert_comment(g_size ==2, "Size of graph is $(g_size) and not 2, find another function.")
    # Get neighbours of vertex
    neighbours = get_vertex_neighbours(resource, vertex) 
    l_neighs = length(neighbours)
    assert_comment(l_neighs==1, "Size of vertex neighbour set is $(l_neighs), needs to be 1, find a different function")
    # Get flow functions
    fflow = get_verified_flow(ForwardFlow(),resource)
    bflow = get_verified_flow(BackwardFlow(),resource)
    bvertex = bflow(vertex)
    fvertex = fflow(vertex)
    # If bvertex is in the graph (``second" vertex)
    if is_vertex_in_graph(resource,bvertex) 
        x_correction_vertex = bvertex
        z_correction_vertices = 0
    # If fvertex is in the graph (``vertex" first)
    elseif is_vertex_in_graph(resource,fvertex) 
        x_correction_vertex = 0
        z_correction_vertices = 0
    else
        @error "From vertex: $(vertex), f(vertex): $(fvertex) and f⁻¹(vertex): $(bvertex) are not in the graph."
    end
    corrections = (X=x_correction_vertex,Z=z_correction_vertices)
    return corrections
end    




"""
    get_corrections_one_neighbourhood_mulit_vertex_graph(resource::MBQCResourceState, vertex::Int64)

This function calculates the corrections needed for a vertex in a multi-vertex graph with one neighbourhood.
It takes the resource state `resource` and the vertex `vertex` as input.

# Arguments
- `resource::MBQCResourceState`: The resource state of the graph.
- `vertex::Int64`: The vertex for which corrections are calculated.

# Returns
- `corrections::NamedTuple`: A named tuple containing the X and Z corrections for the vertex.

# Example
```julia
corrections = get_corrections_one_neighbourhood_mulit_vertex_graph(resource, vertex) # Returns the corrections needed for the given vertex
```
"""
function get_corrections_one_neighbourhood_mulit_vertex_graph(resource::MBQCResourceState,vertex::Int64)
    assert_comment(is_vertex_in_graph(resource,vertex), "Vertex: $(vertex), is not in the graph, find a different function")
    g_size = get_number_vertices(resource)
    assert_comment(g_size > 2, "Size of graph is $(g_size) and not >2, find another function.")
    # Get neighbours of vertex
    neighbours = get_vertex_neighbours(resource, vertex) 
    l_neighs = length(neighbours)
    assert_comment(l_neighs==1, "Size of vertex neighbour set is $(l_neighs), needs to be 1, find a different function")
    # Get flow functions
    fflow = get_verified_flow(ForwardFlow(),resource)
    bflow = get_verified_flow(BackwardFlow(),resource)
    bvertex = bflow(vertex)
    x_correction_vertex = bvertex isa Nothing ? 0 : bvertex
    past_neigbours = bflow.(neighbours)
    filter!(x->!isnothing(x),past_neigbours)
    past_neigbours = Int64.(past_neigbours)
    z_correction_vertices = setdiff(past_neigbours,vertex) 
    z_correction_vertices = length(z_correction_vertices)==0 ? 0 : z_correction_vertices
    z_correction_vertices = setdiff(z_correction_vertices,x_correction_vertex)
    z_correction_vertices = length(z_correction_vertices)==0 ? 0 : z_correction_vertices
    
    corrections = (X=x_correction_vertex,Z=z_correction_vertices)
    return corrections
end    



"""
    get_corrections_multi_neighbourhood_mulit_vertex_graph(resource::MBQCResourceState, vertex::Int64)

This function calculates the corrections needed for a multi-neighbourhood multi-vertex graph in the context of MBQC (Measurement-Based Quantum Computation).

# Arguments
- `resource::MBQCResourceState`: The MBQC resource state.
- `vertex::Int64`: The vertex for which the corrections are calculated.

# Returns
- `corrections`: A tuple containing the X and Z corrections.

# Example
```julia
corrections = get_corrections_multi_neighbourhood_mulit_vertex_graph(resource, vertex) # Returns the corrections needed for the given vertex
```
"""
function get_corrections_multi_neighbourhood_mulit_vertex_graph(resource::MBQCResourceState,vertex::Int64)

    assert_comment(is_vertex_in_graph(resource,vertex), "Vertex: $(vertex), is not in the graph, find a different function") 
    g_size = get_number_vertices(resource)
    assert_comment(g_size > 2, "Size of graph is $(g_size) and not >2, find another function.")
    # Get neighbours of vertex
    neighbours = get_vertex_neighbours(resource, vertex) 
    l_neighs = length(neighbours)
    #assert_comment(l_neighs≠1, "Size of vertex neighbour set is $(l_neighs), needs to not be 1, find a different function")
    # Get flow functions
    fflow = get_verified_flow(ForwardFlow(),resource)
    bflow = get_verified_flow(BackwardFlow(),resource)
    bvertex = bflow(vertex)
    x_correction_vertex = bvertex isa Nothing ? 0 : bvertex
    past_neigbours = bflow.(neighbours)
    filter!(x->!isnothing(x),past_neigbours)
    past_neigbours = Int64.(past_neigbours)
    z_correction_vertices = setdiff(past_neigbours,vertex) 
    z_correction_vertices = length(z_correction_vertices)==0 ? 0 : z_correction_vertices
    z_correction_vertices = setdiff(z_correction_vertices,x_correction_vertex)
    z_correction_vertices = length(z_correction_vertices)==0 ? 0 : z_correction_vertices
    
    corrections = (X=x_correction_vertex,Z=z_correction_vertices)
    return corrections
end    




"""
    get_correction_vertices(resource::MBQCResourceState, vertex::Int64)

Returns the corrections for a given vertex in the MBQC resource state.

# Arguments
- `resource::MBQCResourceState`: The MBQC resource state.
- `vertex::Int64`: The vertex for which to get the corrections.

# Returns
- `corrections`: A tuple containing the X and Z corrections.

# Example
```julia
corrections = get_correction_vertices(resource, vertex) # Returns the corrections needed for the given vertex
```
"""
function get_correction_vertices(resource::MBQCResourceState,vertex::Int64)
    # Assert we do not have the singleton graph. No functionality here.
    g_size = get_number_vertices(resource)
    assert_comment(g_size > 1, "Size of graph is $(g_size), the singleton graph is just measured, no corrections needed.")
    # Get neighbours of vertex
    neighbours = get_vertex_neighbours(resource, vertex) 
    l_neighs = length(neighbours)
    # Get flow functions

    if l_neighs == 1 && g_size == 2
        corrections = get_corrections_one_neighbourhood_two_vertex_graph(resource,vertex)
    elseif l_neighs == 1 && g_size > 2
        corrections = get_corrections_one_neighbourhood_mulit_vertex_graph(resource,vertex)
    elseif l_neighs ≠ 1 && g_size > 2
        corrections = get_corrections_multi_neighbourhood_mulit_vertex_graph(resource,vertex)
    else
        @warn "No other conditions for vertex: $(vertex) in function: get_correction_vertices were met. Meaning the size of the neighbourhood was neither 1 nor ≠1 and the graph size was neither 1 (an assert at the beginning of the function), nor 2 nor >2, check function. Returning X and Z corrections as 0"
        corrections = (X=0,Y=0)
    end
    return corrections
end




