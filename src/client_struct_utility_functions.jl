##################################################################
# Filename  : struct_utility_functions.jl
# Author    : Jonathan Miller
# Date      : 2023-07-07
# Aim       : aim_script
#           : Write function to assist in the ut
#           :
##################################################################


function assert_comment(condition,message)
    @assert condition message
end


function throw_error(::DummyQubitZeroOneInitialisationError)
    @error "Input qubit value is either a 1 or a 0, both integers, seeing this error means neither 0 or 1 integer was passed."
end
function throw_error(::QubitFloatPhaseInitialisationError)
    @error "Input qubit value is meant to be a Float64 for a plus state with a phase, seeing this error means the input value was not a Float64."
end


function throw_warning(::FunctionNotMeantToBeUsed)
    @warn "This function is not meant to be used anymore, this is a generic warning message. Find out what function is throwing this issue"
end





function get_vector_graph_colors(graph;reps=100)
    g_cols = generate_random_greedy_color(graph,reps)        
    separate_each_color(g_cols)
end


function create_graph_resource(p::NamedTuple)::MBQCResourceState
    input = MBQCInput(p[:input_indices],p[:input_values]) 
    output = MBQCOutput(p[:output_indices])
    colors = MBQCColouringSet(p[:computation_colours],p[:test_colours])
    mbqc_graph = MBQCGraph(p[:graph],colors,input,output)
    mbqc_flow = MBQCFlow(p[:forward_flow],p[:backward_flow])
    mbqc_angles = MBQCAngles(p[:secret_angles],p[:public_angles])
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

function get_input_indices(resource::MBQCResourceState)
    return resource.graph.input.indices
end

function get_input_values(resource::MBQCResourceState)
    return resource.graph.input.values
end

function get_input_value(resource::MBQCResourceState,iter)
    input_values = get_input_values(resource)
    input_indices = get_input_indices(resource)
    len_input_indices = length(input_indices)
    iter > len_input_indices && return nothing
    return input_values[input_indices[iter]]
end

function get_angles(resource::MBQCResourceState)
    return resource.angles.angles
end

function get_angle(resource::MBQCResourceState,vertex)
    return get_angles(resource)[vertex]
end

function get_graph(resource::MBQCResourceState)
    return resource.graph.graph
end

function get_flow(::BackwardFlow,resource::MBQCResourceState)
    return resource.flow.backward_flow
end

function get_flow(::ForwardFlow,resource::MBQCResourceState)
    return resource.flow.forward_flow
end


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
        else
            return 
        end
    elseif T isa BackwardFlow
        new_vertex = flow(vertex)
        if issubset(new_vertex,neighs)
            new_vertex_in_intersection = 
                intersect(neighs,new_vertex)
            @assert length(new_vertex_in_intersection)==1 "Intersection of neighbourhood of vertex and forward vertex should be 1, it is $(lenth(new_vertex_in_intersection)), figure out problem."
            return new_vertex_in_intersection[1]
        else
            return 
        end
    else
        @error "Type for flow must be ForwardFlow or BackwardFlow, it is $(T), fix"
    end
end

function get_verified_flow(T,resource::MBQCResourceState)
    f(vertex) = get_verified_flow_output(T,resource,vertex)
    return f
end



function get_input_size(resource::MBQCResourceState)::Int64
    return length(resource.graph.input.indices)
end

function get_output_size(resource::MBQCResourceState)::Int64
    return length(resource.graph.output.indices)
end



function get_minimum_vertex_index_flow(resource::MBQCResourceState)::Int64
    min_num_vertices_to_skip = get_input_size(resource)
    # Return next vertex index after size of input
    return min_num_vertices_to_skip +=1
end



function get_size_measurement_vector(resource::MBQCResourceState)::Int64
    min_num_vertices_to_stop_before = get_output_size(resource)
    num_vertices = get_number_vertices(resource)
    iszero(min_num_vertices_to_stop_before) && return num_vertices
    return num_vertices - min_num_vertices_to_stop_before
end

function get_measurement_outcome_iterator(resource::MBQCResourceState)::Base.OneTo{Int64}
    total_vertices_to_measure = get_size_measurement_vector(resource)
    total_vertices_to_measure -=1
    return Base.OneTo(total_vertices_to_measure)
end



function get_stop_start_vertices(resource::MBQCResourceState)::Tuple{Int64,Int64}
    start_vertex = get_minimum_vertex_index_flow(resource)
    stop_vertex = get_size_measurement_vector(resource)
    return (start_vertex,stop_vertex) 
end



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

function is_vertex_in_graph(resource::MBQCResourceState,vertex::Int64)
    verts = get_vertex_iterator(resource)
    vertex ∈ verts
end


function is_vertex_in_graph(resource::MBQCResourceState,novertex::Nothing)
    return false
end



function assert_flow(::ForwardFlow,resource::MBQCResourceState,vertex::Int64)
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




