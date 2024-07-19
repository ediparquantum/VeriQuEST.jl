##################################################################
# Filename  : flow.jl
# Author    : Jonathan Miller
# Date      : 2024-03-12
# Aim       : aim_script
#           : Bring together all flow related functions
#           : 
##################################################################

"""
# Definition of Flow
- `forward_flow`, `f`: Oᶜ → Iᶜ is a mapping `v ↦ f(v)` with an inverse `f⁻¹(v) ↦ v`, with partial order "≤". The partial order is said to map the present to the future or the present to the past.
- (a) `v ∼ f(v)`, where "∼" defines the neighbourhood `N(f(v))` and `v` has set membership.
- (b) `v ≤ f(v)`
- (c) `w ∼ f(v)`, then ∀ `v`, `v ≤ w`
"""

mutable struct Flow <: AbstractQuantumFlow
    forward::Function
    backward::Union{Function,Missing}
    function Flow(forward)
        new(forward,missing)
    end
    function Flow(forward,backward)
        new(forward,backward)
    end
end


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

function forward_flow() end
function get_forward_flow(flow::AbstractQuantumFlow)
    flow.forward
end

function get_backward_flow(flow::AbstractQuantumFlow)
    flow.backward
end

function set_forward_flow!(flow::AbstractQuantumFlow,forward::Function)
    flow.forward = forward
end

function set_backward_flow!(flow::AbstractQuantumFlow,backward::Function)
    flow.backward = backward
end



#=
function get_flow(::BackwardFlow,resource::AbstractParameterResources)
    get_computation_type(resource) |> 
    get_flow |>
    get_backward_flow
end


function get_flow(::ForwardFlow,resource::AbstractParameterResources)
    get_computation_type(resource) |> 
    get_flow |>
    get_forward_flow
end
=#



function get_verified_flow_output(T,resource::AbstractParameterResources,vertex::Int64)
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



function get_verified_flow(T,resource::AbstractParameterResources)
    f(vertex) = get_verified_flow_output(T,resource,vertex)
    return f
end




function get_minimum_vertex_index_flow(resource::AbstractParameterResources)::Int64
    min_num_vertices_to_skip = get_input_size(resource)
    # Return next vertex index after size of input
    return min_num_vertices_to_skip +=1
end



function is_vertex_in_graph(resource::AbstractParameterResources, vertex::Int64)
    verts = get_vertex_iterator(resource)
    vertex ∈ verts
end




function is_vertex_in_graph(resource::AbstractParameterResources, novertex::Nothing)
    return false
end


function assert_flow(::ForwardFlow, resource::AbstractParameterResources, vertex::Int64)
    T = ForwardFlow()
    flow = get_flow(T,resource)
    new_vertex = flow(vertex)    
    is_in_graph = is_vertex_in_graph(resource,new_vertex)
    verts = get_vertex_iterator(resource)
    assert_comment(is_in_graph, "f(vertex), $(new_vertex), is not in the vertex set, $(verts |> collect).")
    new_neighbours = get_vertex_neighbours(resource, new_vertex)
    assert_comment(vertex ∈ new_neighbours, "Vertex, $(vertex), is not in the nieghbourhood, $(new_neighbours), of the f(vertex), $(new_vertex), Flow C1")
    assert_comment(vertex ≤ new_vertex, "Vertex, $(vertex), is not less than or equal to f(vertex), $(new_vertex), Flow C2" )
    assert_comment(all(vertex .≤ new_neighbours), "Vertex, $(vertex), is not less than or equal to the nieghbourhood, $(new_neighbours), of the f(vertex), $(new_vertex), Flow C3")
end


function assert_flow(::BackwardFlow,resource::AbstractParameterResources,vertex::Int64)
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


function get_corrections_one_neighbourhood_two_vertex_graph(resource::AbstractParameterResources,vertex::Int64)
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



function get_corrections_one_neighbourhood_mulit_vertex_graph(resource::AbstractParameterResources,vertex::Int64)
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


function get_corrections_multi_neighbourhood_mulit_vertex_graph(resource::AbstractParameterResources,vertex::Int64)

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



function get_correction_vertices(resource::AbstractParameterResources,vertex::Int64)
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




