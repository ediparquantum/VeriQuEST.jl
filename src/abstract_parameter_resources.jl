##################################################################
# Filename  : abstract_parameter_resources.jl
# Author    : Jonathan Miller
# Date      : 2024-03-12
# Aim       : aim_script
#           : Struct construction and associated methods
#           : Direct methods with mainly get/set type stuff
##################################################################

struct ParameterResources <: AbstractParameterResources
    computation_type::AbstractQuantumComputation
    network_type::AbstractNetworkEmulation
    state_type::AbstractQuantumState

 

    function ParameterResources(computation_type,network_type,state_type)
        # Make sure MBQC is set as NoNetworkEmulation
        if (computation_type isa MeasurementBasedQuantumComputation) &&
           !(network_type isa NoNetworkEmulation) 
            error("The $(typeof(computation_type)) is not defined with $(typeof(network_type)), use  NoNetworkEmulation.")
        elseif (computation_type isa AbstractBlindQuantumComputation || computation_type isa AbstractVerifiedBlindQuantumComputation) && 
            !(network_type isa AbstractImplicitNetworkEmulation || network_type isa AbstractExplicitNetworkEmulation) 
            error("$(typeof(computation_type)) is not defined with $(typeof(network_type)), use a subtype of either AbstractImplicitNetworkEmulation or AbstractExplicitNetworkEmulation.")
        elseif (computation_type isa AbstractBlindQuantumComputation || computation_type isa AbstractVerifiedBlindQuantumComputation) && 
            (network_type isa AbstractExplicitNetworkEmulation) && 
            !(state_type isa DensityMatrix)
            error("$(typeof(computation_type)) and $(typeof(network_type)) is not defined with $(typeof(state_type)), use DensityMatrix for quantum state instead. ")
        else
            nothing
        end
        # Compute reverse flow function 
        set_backwards_flow!(computation_type)
        new(computation_type,network_type,state_type)
    end

        # Allow for MBQC to not input a network type
    function ParameterResources(computation_type::MeasurementBasedQuantumComputation,state_type::AbstractQuantumState)
        # Compute reverse flow function 
        set_backwards_flow!(computation_type)
        set_colouring!(computation_type)
        new(computation_type,NoNetworkEmulation(),state_type)
    end

    function ParameterResources(computation_type::MeasurementBasedQuantumComputation,network_type::AbstractNetworkEmulation,state_type::AbstractQuantumState)
        # Compute reverse flow function 
        set_backwards_flow!(computation_type)
        set_colouring!(computation_type)
        new(computation_type,network_type,state_type)
    end

    function ParameterResources(computation_type::Union{AbstractBlindQuantumComputation,AbstractVerifiedBlindQuantumComputation},network_type::AbstractExplicitNetworkEmulation)
        # Compute reverse flow function 
        set_backwards_flow!(computation_type)
        set_colouring!(computation_type)
        new(computation_type,network_type,DensityMatrix())
    end

    function ParameterResources(computation_type::Union{AbstractBlindQuantumComputation,AbstractVerifiedBlindQuantumComputation},network_type::AbstractImplicitNetworkEmulation,state_type::AbstractQuantumState)
        # Compute reverse flow function 
        set_backwards_flow!(computation_type)
        set_colouring!(computation_type)
        new(computation_type,network_type,state_type)
    end

end



function get_computation_type(resource::AbstractParameterResources)
    resource.computation_type
end

function get_network_type(resource::AbstractParameterResources)
    resource.network_type
end

function get_state_type(resource::AbstractParameterResources)
    resource.state_type
end



function get_graph(resource::AbstractParameterResources)
    get_computation_type(resource) |> get_graph |> get_graph 
end




function get_colouring(resource::AbstractParameterResources,::ComputationColouring)
    get_computation_type(resource) |> 
    get_colouring |> 
    x -> get_colouring(ComputationColouring(),x) |> 
    get_colouring
end

function get_colouring(resource::AbstractParameterResources,::TestColouring)
    get_computation_type(resource) |> 
    get_colouring |> 
    x -> get_colouring(TestColouring(),x) |> 
    get_colouring
end

function get_output_indices(resource::AbstractParameterResources)
    get_computation_type(resource) |> 
    get_graph |> 
    get_io |>
    get_outputs |>
    get_indices
end



function get_input_indices(resource::AbstractParameterResources)
    get_computation_type(resource) |> 
    get_graph |> 
    get_io |>
    get_inputs |>
    get_indices
end

function get_input_values(resource::AbstractParameterResources)
    get_computation_type(resource) |> 
    get_graph |> 
    get_io |>
    get_inputs |>
    get_values
end

function get_flow(resource::AbstractParameterResources)
    com_typ = get_computation_type(resource)
    get_flow(com_typ)
end
function get_flow(::ForwardFlow,resource::AbstractParameterResources)
    get_flow(resource).forward
end

function get_flow(::BackwardFlow,resource::AbstractParameterResources)
    get_flow(resource).backward
end





function are_there_classical_inputs(resource::AbstractParameterResources)
    idx_vec = get_input_indices(resource)
    val_vec = get_input_values(resource)
    no_inputs_bool = ((typeof(idx_vec) isa Vector{Missing} || typeof(idx_vec) isa Missing) &&
    (typeof(val_vec) isa Vector{Missing} || typeof(val_vec) isa Missing))
    if no_inputs_bool
        return true
    else
        return false
    end
end



# Iterators
function get_edge_iterator(resource::AbstractParameterResources)
    get_graph(resource) |> edges
end

function get_vertex_iterator(resource::AbstractParameterResources)
    get_graph(resource) |> vertices
end


# Scalers
function get_number_vertices(resource::AbstractParameterResources)
    get_graph(resource) |> nv
end


function get_input_size(resource::AbstractParameterResources)::Int64
    ii = get_input_indices(resource)
    if ii isa Missing || ii isa Vector{Missing}
        @warn "No inputs found, returning 0"
        return 0
    else
        return length(ii)
    end
end


function get_output_size(resource::AbstractParameterResources)::Int64
    oi = get_output_indices(resource)
    if oi isa Missing || oi isa Vector{Missing}
        @error "This simulator required BQP to have outputs, none found."
    else
        return length(oi)
    end
end


# Sets
function get_vertex_neighbours(resource::AbstractParameterResources, vertex)
    g = get_graph(resource)
    return all_neighbors(g, vertex)
end



function get_angles(resource::AbstractParameterResources)
    get_computation_type(resource) |> get_angles |> get_angles 
end

function get_angle(resource::AbstractParameterResources,vertex)
    return get_angles(resource)[vertex]
end




function get_size_measurement_vector(resource::AbstractParameterResources)::Int64
    min_num_vertices_to_stop_before = get_output_size(resource)
    num_vertices = get_number_vertices(resource)
    iszero(min_num_vertices_to_stop_before) && return num_vertices
    return num_vertices - min_num_vertices_to_stop_before
end




function get_measurement_outcome_iterator(resource::AbstractParameterResources)::Base.OneTo{Int64}
    total_vertices_to_measure = get_size_measurement_vector(resource)
    total_vertices_to_measure -=1
    return Base.OneTo(total_vertices_to_measure)
end



function get_stop_start_vertices(resource::AbstractParameterResources)::Tuple{Int64,Int64}
    start_vertex = get_minimum_vertex_index_flow(resource)
    stop_vertex = get_size_measurement_vector(resource)
    return (start_vertex,stop_vertex) 
end



function init_outcomes_vector(resource::AbstractParameterResources)::Vector
    max_index_to_be_measured = get_size_measurement_vector(resource)    
    input_values = get_input_values(resource)
    input_indices = get_input_indices(resource) 
    outcomes_vec = Vector(undef, max_index_to_be_measured)
    if are_there_classical_inputs(resource)
        for i in input_indices
            outcomes_vec[i] = input_values[i]
        end
    end
    return outcomes_vec
end



