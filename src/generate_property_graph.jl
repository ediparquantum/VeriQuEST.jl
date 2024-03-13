##################################################################
# Filename  : generate_property_graph.jl
# Author    : Jonathan Miller
# Date      : 2024-03-13
# Aim       : aim_script
#           : Property graph generation
#           : All quantum action takes place after the graph is generated
##################################################################



function MetaGraph(::Client,resource::AbstractParameterResources)
    g = get_graph(resource)
    return MetaGraphs.MetaGraph(g)
end

function add_round_type!(::Client,mg::MetaGraphs.MetaGraph{Int64, Float64},round_type)
    set_prop!(mg,:round_type,round_type) # Set round to graph
    mg
end

function add_state_type!(::Client,mg::MetaGraphs.MetaGraph{Int64, Float64},resource::AbstractParameterResources)
    state_type = get_state_type(resource)
    set_prop!(mg,:state_type,state_type)
    return mg
end




function set_vertex_type!(::ComputationRound,mg::MetaGraphs.MetaGraph{Int64, Float64},resource::AbstractParameterResources)
    color_pattern = get_colouring(resource,ComputationColouring())
    qubit_types = [ComputationQubit()]
    vertex_qubit_types_list = [qubit_types[i] for i in color_pattern]
    [set_prop!(mg,i,:vertex_type,vertex_qubit_types_list[i]) for i in vertices(mg)]
    return mg
end

function set_vertex_type!(::TestRound,mg::MetaGraphs.MetaGraph{Int64, Float64},resource::AbstractParameterResources)
    g_diff_cols = get_colouring(resource,TestColouring())
    color_pattern = get_random_coloring(g_diff_cols)
    # Colouring separates each color into a vector of 1s 
    # 2s, the 2s are the traps.
    qubit_types = [DummyQubit(),TrapQubit()] 
    vertex_qubit_types_list = [qubit_types[i] for i in color_pattern]
    [set_prop!(mg,i,:vertex_type,vertex_qubit_types_list[i]) for i in vertices(mg)]
    return mg
end



function set_vertex_type!(::Client,mg::MetaGraphs.MetaGraph{Int64, Float64},resource::AbstractParameterResources)
    round_type = get_prop(mg,:round_type)
    set_vertex_type!(round_type,mg,resource)
    return mg
end

function add_output_qubits!(::Client,mg::MetaGraphs.MetaGraph{Int64, Float64},resource::AbstractParameterResources)
    output_inds = get_output_indices(resource)
    set_prop!(mg,:output_inds,output_inds)
end


function no_input_vertices!(mg::MetaGraphs.MetaGraph{Int64, Float64},resource::AbstractParameterResources)
    vertex_iterator = get_vertex_iterator(resource)
    set_prop!.(Ref(mg),vertex_iterator,:vertex_io_type,Ref(NoInputQubits())) 
end

function with_input_vertices!(mg::MetaGraphs.MetaGraph{Int64, Float64},resource::AbstractParameterResources)
    idx_vec = get_input_indices(resource)
    val_vec = get_input_values(resource)
    vertex_iterator = get_vertex_iterator(resource)
    for v in vertex_iterator
        in_bool = v ∈ idx_vec
        in_bool ? set_props!(mg,v,Dict(:vertex_io_type => InputQubits(),:classic_input => val_vec[v])) : 
            set_prop!(mg,v,:vertex_io_type,NoInputQubits())
    end
end

function set_io_qubits_type!(mg::MetaGraphs.MetaGraph{Int64, Float64},resource::AbstractParameterResources)
    input_no_input = are_there_classical_inputs(resource)
    if input_no_input
        with_input_vertices!(mg,resource)
    else
        no_input_vertices!(mg,resource)
    end
end

function set_io_qubits_type!(::ComputationRound,mg::MetaGraphs.MetaGraph{Int64, Float64},resource::AbstractParameterResources)
    set_io_qubits_type!(mg::MetaGraphs.MetaGraph{Int64, Float64},resource::AbstractParameterResources)
end


function set_io_qubits_type!(::TestRound,mg::MetaGraphs.MetaGraph{Int64, Float64},resource::AbstractParameterResources)
    no_input_vertices!(mg,resource)
end

function set_io_qubits_type!(::Client,mg::MetaGraphs.MetaGraph{Int64, Float64},resource::AbstractParameterResources)
    round_type = get_prop(mg,:round_type)
    set_io_qubits_type!(round_type,mg,resource)
end





function init_qubit_meta_graph!(::ComputationRound,::MeasurementBasedQuantumComputation,mg::MetaGraphs.MetaGraph{Int64, Float64},resource::AbstractParameterResources) 
    verts = get_vertex_iterator(resource)
    for v in verts
        ϕ = get_angle(resource,v) 
        set_prop!(mg,v,:secret_angle,ϕ)
        set_prop!(mg,v,:init_qubit,ϕ)
    end
    return mg
end

function init_qubit_meta_graph!(::ComputationRound,::AbstractBlindQuantumComputation,mg::MetaGraphs.MetaGraph{Int64, Float64},resource::AbstractParameterResources) 
    verts = get_vertex_iterator(resource)
    for v in verts
        θ = draw_θᵥ()
        ϕ = get_angle(resource,v) 
        set_prop!(mg,v,:secret_angle,ϕ)
        set_prop!(mg,v,:init_qubit,θ)
    end
    return mg
end

function init_qubit_meta_graph!(::ComputationRound,::AbstractVerifiedBlindQuantumComputation,mg::MetaGraphs.MetaGraph{Int64, Float64},resource::AbstractParameterResources)
    init_qubit_meta_graph!(ComputationRound(),BlindQuantumComputationFlag(),mg,resource) 
end

function init_qubit_meta_graph!(::TestRound,::AbstractVerifiedBlindQuantumComputation,mg::MetaGraphs.MetaGraph{Int64, Float64},resource::AbstractParameterResources) 
    verts = get_vertex_iterator(resource)    
    for v in verts
        qubit_type = get_prop(mg,v,:vertex_type) 
        init_qubit_value = init_qubit(qubit_type)
        set_prop!(mg,v,:init_qubit,init_qubit_value)
    end
    return mg
end

function init_qubit_meta_graph!(::Client,mg::MetaGraphs.MetaGraph{Int64, Float64},resource::AbstractParameterResources)
    round_type = get_prop(mg,:round_type)
    computation_type = get_computation_type(resource) 
    init_qubit_meta_graph!(round_type,computation_type,mg,resource)
end




function add_flow_vertex!(
    ::Client,
    mg::MetaGraphs.MetaGraph{Int64, Float64},
    resource::AbstractParameterResources,
    flow_type::Union{ForwardFlow,BackwardFlow})

    flow_sym = convert_flow_type_symbol(Client(),flow_type)
    verts = get_vertex_iterator(resource)
    for v in verts
        fv = get_verified_flow_output(flow_type,resource,v)
        set_prop!(mg,v,flow_sym,fv)
    end
    return mg
end


function add_flow_vertex!(::Client,mg::MetaGraphs.MetaGraph{Int64, Float64},resource::AbstractParameterResources)
    add_flow_vertex!(Client(),mg,resource,ForwardFlow())
    add_flow_vertex!(Client(),mg,resource,BackwardFlow())
end



function add_correction_vertices!(::Client,mg::MetaGraphs.MetaGraph{Int64, Float64},resource::AbstractParameterResources)
    verts = get_vertex_iterator(resource)
    for v in verts
        cor = get_correction_vertices(resource,v)
        set_props!(mg,v,Dict(:X_correction => cor[:X],:Z_correction => cor[:Z]))
    end
    return mg
end


function init_measurement_outcomes!(::Client,mg::MetaGraphs.MetaGraph{Int64, Float64},resource::AbstractParameterResources)
    verts = get_vertex_iterator(resource)
    for v in verts
        set_prop!(mg,v,:outcome,Int64)
    end
    return mg
end


function generate_property_graph!(
    ::Client,
    round_type,
    resource::AbstractParameterResources)
    mg = MetaGraph(Client(),resource)
    add_state_type!(Client(),mg,resource)
    add_round_type!(Client(),mg,round_type)
    add_output_qubits!(Client(),mg,resource)
    set_vertex_type!(Client(),mg,resource)
    set_io_qubits_type!(Client(),mg,resource)
    init_qubit_meta_graph!(Client(),mg,resource)
    add_flow_vertex!(Client(),mg,resource)
    add_correction_vertices!(Client(),mg,resource)
    init_measurement_outcomes!(Client(),mg,resource)
    return mg
end
 round_type = ComputationRound()