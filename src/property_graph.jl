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

function add_computation_type_to_graph!(::Client,mg::MetaGraphs.MetaGraph{Int64, Float64},resource::AbstractParameterResources)
    #computation_type = typeof(get_computation_type(resource))
    computation_type = get_computation_type(resource)
    set_prop!(mg,:computation_type,computation_type)
end

function add_network_type_to_graph!(::Client,mg::MetaGraphs.MetaGraph{Int64, Float64},resource::AbstractParameterResources)
    #network_type = typeof(get_network_type(resource))
    network_type = get_network_type(resource)
    set_prop!(mg,:network_type,network_type)
end

function add_state_type!(::Client,mg::MetaGraphs.MetaGraph{Int64, Float64},resource::AbstractParameterResources)
    state_type = get_state_type(resource)
    set_prop!(mg,:state_type,state_type)
    return mg
end

function add_round_type!(::Client,mg::MetaGraphs.MetaGraph{Int64, Float64},round_type)
    set_prop!(mg,:round_type,round_type) # Set round to graph
    mg
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



function set_vertex_type!(::MBQCRound,mg::MetaGraphs.MetaGraph{Int64, Float64},resource::AbstractParameterResources)
    color_pattern = get_colouring(resource,ComputationColouring())
    qubit_types = [ComputationQubit()]
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

function set_io_qubits_type!(::Union{MBQCRound,ComputationRound},mg::MetaGraphs.MetaGraph{Int64, Float64},resource::AbstractParameterResources)
    set_io_qubits_type!(mg::MetaGraphs.MetaGraph{Int64, Float64},resource::AbstractParameterResources)
end


function set_io_qubits_type!(::TestRound,mg::MetaGraphs.MetaGraph{Int64, Float64},resource::AbstractParameterResources)
    no_input_vertices!(mg,resource)
end

function set_io_qubits_type!(::Client,mg::MetaGraphs.MetaGraph{Int64, Float64},resource::AbstractParameterResources)
    round_type = get_prop(mg,:round_type)
    set_io_qubits_type!(round_type,mg,resource)
end


function init_qubit(::TrapQubit)::Float64
    draw_θᵥ()
end

function init_qubit(::DummyQubit)::Int64
    draw_dᵥ()
end



function init_qubit_meta_graph!(::MBQCRound,::MeasurementBasedQuantumComputation,mg::MetaGraphs.MetaGraph{Int64, Float64},resource::AbstractParameterResources) 
    verts = get_vertex_iterator(resource)
    for v in verts
        set_prop!(mg,v,:init_qubit,0.0)
        ϕ = get_angle(resource,v) 
        set_prop!(mg,v,:secret_angle,ϕ)
        
    end
    return mg
end


function init_qubit_meta_graph!(::ComputationRound,::AbstractBlindQuantumComputation,mg::MetaGraphs.MetaGraph{Int64, Float64},resource::AbstractParameterResources) 
    verts = get_vertex_iterator(resource)
    for v in verts
        θ = draw_θᵥ()
        set_prop!(mg,v,:init_qubit,θ)
        ϕ = get_angle(resource,v) 
        set_prop!(mg,v,:secret_angle,ϕ)
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
    add_computation_type_to_graph!(Client(),mg,resource)
    add_network_type_to_graph!(Client(),mg,resource)
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


produce_initialised_graph(::Client,mg) = Graph(mg)



function create_quantum_state(mg::MetaGraphs.MetaGraph{Int64, Float64})
    state_type = get_prop(mg,:state_type)
    network_type = get_prop(mg,:network_type)
    num_vertices = nv(mg)
    num_qubits = get_num_qubits(num_vertices,network_type)
    quantum_env = createQuESTEnv()
   create_quantum_state(state_type,quantum_env,num_qubits)
end


get_network_type(mg::MetaGraphs.MetaGraph{Int64, Float64}) = get_prop(mg,:network_type)


function store_measurement_outcome!(
    ::Client,
    mg::MetaGraphs.MetaGraph{Int64, Float64},
    qubit::Union{Int64,Int32,Int},
    outcome::Union{Int64,Int32,Int})
    set_prop!(mg,qubit,:outcome, outcome)
end




function initialise_state!(mg::MetaGraphs.MetaGraph{Int64, Float64},network_type::AbstractNoNetworkEmulation)
    qureg = create_quantum_state(mg)
    set_quantum_backend!(network_type,qureg)
    teleport!(network_type)
end

function initialise_state!(mg::MetaGraphs.MetaGraph{Int64, Float64},network_type::AbstractImplicitNetworkEmulation)
    qureg = create_quantum_state(mg)
    qubit_types = [get_prop(mg,i,:vertex_type) for i in vertices(mg)]
    basis_init_angles = [Float64(get_prop(mg,i,:init_qubit)) for i in vertices(mg)]
    set_quantum_backend!(network_type,qureg)
    set_qubit_types!(network_type,qubit_types)
    set_basis_init_angles!(network_type,basis_init_angles)
    teleport!(network_type)
end

function initialise_state!(mg::MetaGraphs.MetaGraph{Int64, Float64},network_type::AbstractBellPairExplicitNetwork)
    @info "Create quantum state"
    qureg = create_quantum_state(mg)
    qubit_types = [get_prop(mg,i,:vertex_type) for i in vertices(mg)]
    @info "Got qubit types: $(qubit_types)"
    client_indices = [1] # Hardcoded for now
    @info "Client index: $(client_indices)"
    basis_init_angles = [Float64(get_prop(mg,i,:init_qubit)) for i in vertices(mg)]
    @info "Client angles: $(basis_init_angles)"
    set_quantum_backend!(network_type,qureg)
    set_client_indices!(network_type,client_indices)
    set_qubit_types!(network_type,qubit_types)
    set_basis_init_angles!(network_type,basis_init_angles)
    set_server_indices!(network_type)
    set_bell_pairs!(network_type)
    teleport!(network_type)
    @info "Teleported"
end



function initialise_state!(mg::MetaGraphs.MetaGraph{Int64, Float64})
    network_type = get_network_type(mg)
    initialise_state!(mg,network_type)
end

function initialise_add_noise_entangle!(mg::MetaGraphs.MetaGraph{Int64, Float64},channel::NoisyChannel)
    init_quantum_state = initialise_state!(mg)
    update_init_angles!(mg,init_quantum_state) # Update angles from state init
    add_noise!(channel,init_quantum_state) 
    entangle_graph!(mg,init_quantum_state)
    set_prop!(mg,:quantum_state_properties,init_quantum_state)
    set_prop!(mg,:noisy_channel,channel)
    mg  
end



function adjust_vertex(::BellPairExplicitNetwork,vertex::Union{Int,Int32,Int64})
    vertex - 1
end

function adjust_vertex(::Union{NoNetworkEmulation,ImplicitNetworkEmulation},vertex::Union{Int,Int32,Int64})
    vertex
end

function adjust_vertex(mg::MetaGraphs.MetaGraph{Int64, Float64},vertex::Union{Int,Int32,Int64})
    network_type = get_network_type(mg)
    adjust_vertex(network_type,vertex)
end