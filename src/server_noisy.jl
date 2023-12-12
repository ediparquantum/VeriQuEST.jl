##################################################################
# Filename  : server_noisy.jl
# Author    : Jonathan Miller
# Date      : 2023-11-29
# Aim       : Making script to perform noisy operations

#           :
##################################################################


#=
function add_noise!(
    ::Server,
    model::Union{Damping,Dephasing,Depolarising,Pauli,Kraus},
    params::Union{QubitNoiseParameters,KrausMapNoiseParameters})
    !(model.type isa SingleQubit) && 
        throw_error(OnlySingleQubitNoiseInUseError())
    qubit_range = Base.OneTo(params.ρ.numQubitsRepresented)
    for q in qubit_range
        params.q = q
        add_noise!(model,params)
    end
end

function add_noise!(::Server,
    model::MixtureDensityMatrices,
    params::DensityMatrixMixtureParameters)
    add_noise!(model,params)
end
=#
function add_noise!(
    server::NoisyServer,
    server_qureg)
    server_copy = server
    models = server_copy.noise_model
    if models isa Vector 
        for m in eachindex(models)
            model = models[m]
            params = get_noise_model_params(model,server_qureg)
            qubit_range = Base.OneTo(params.ρ.numQubitsRepresented)
            if length(model.prob) == 1
                for q in qubit_range
                    params.q = q
                    add_noise!(model,params)
                end
            elseif length(model.prob) > 1
                probs = model.prob
                for q in qubit_range
                    model.prob = probs[q]
                    params.q = q
                    add_noise!(model,params)
                end
            
            end
        end
    elseif !(models isa Vector)
        params = get_noise_model_params(models,server_qureg)
        qubit_range = Base.OneTo(params.ρ.numQubitsRepresented)
        if length(models.prob) == 1
            for q in qubit_range
                params.q = q
                add_noise!(models,params)
            end
        elseif length(models.prob) > 1
            probs = models.prob
            for q in qubit_range
                models.prob = probs[q]
                params.q = q
                add_noise!(models,params)
            end
        
        end
    end
end




function create_resource(server::NoisyServer,client_graph,client_qureg)
    # Server copies/clones data and structures
    server_graph = clone_graph(Server(),client_graph)
    server_env = create_quantum_env(Server())
    server_qureg = clone_qureq(Server(),client_qureg,server_env)
   
    # Server adds noise
    server_copy = deepcopy(server)
    add_noise!(server_copy,server_qureg)


    #  Server entangles graph
    entangle_graph!(Server(),server_qureg,server_graph)
    return Dict("env"=>server_env,"quantum_state"=>server_qureg,"graph"=>server_graph)
end


function run_verification(client::Client,server::NoisyServer,
    round_types,client_resource,state_type)

    round_graphs = []
    for round_type in round_types
        
        # Generate client meta graph
        client_meta_graph = generate_property_graph!(
            client,
            round_type,
            client_resource,
            state_type)
        

        # Extract graph and qureg from client
        client_graph = produce_initialised_graph(client,client_meta_graph)
        client_qureg = produce_initialised_qureg(client,client_meta_graph)
        
      
        # Create server resources
        server_resource = create_resource(server,client_graph,client_qureg)
        server_quantum_state = server_resource["quantum_state"]
        num_qubits_from_server = server_quantum_state.numQubitsRepresented
        
        run_computation(client,server,client_meta_graph,num_qubits_from_server,server_quantum_state)
    #run_computation(Client(),Server(),client_meta_graph,num_qubits_from_server,server_quantum_state)
       
        initialise_blank_quantum_state!(server_quantum_state)

        push!(round_graphs,client_meta_graph)
    end

    round_graphs
end



function run_verification_simulator(server::NoisyServer,::Terse,para)
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

    round_types = draw_random_rounds(para[:total_rounds],para[:computation_rounds])

    rounds_as_graphs = run_verification(
        client,server,
        round_types,client_resource,
        para[:state_type])

    test_verification = verify_rounds(client,TestRound(),Terse(),rounds_as_graphs,test_rounds_theshold)
    computation_verification = verify_rounds(client,ComputationRound(),Terse(),rounds_as_graphs)
    mode_outcome = get_mode_output(client,ComputationRound(),rounds_as_graphs)

    return (
        test_verification = test_verification,
        computation_verification = computation_verification,
        mode_outcome = mode_outcome)
end



function run_verification_simulator(server::NoisyServer,::Verbose,para)
   
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

    round_types = draw_random_rounds(para[:total_rounds],para[:computation_rounds])
    client = Client()
    
    rounds_as_graphs = run_verification(
        client,server,
        round_types,client_resource,
        para[:state_type])

    test_verification = verify_rounds(client,TestRound(),Terse(),rounds_as_graphs,test_rounds_theshold)
    computation_verification = verify_rounds(client,ComputationRound(),Terse(),rounds_as_graphs)
    test_verification_verb = verify_rounds(client,TestRound(),Verbose(),rounds_as_graphs,test_rounds_theshold)
    computation_verification_verb = verify_rounds(client,ComputationRound(),Verbose(),rounds_as_graphs)
    mode_outcome = get_mode_output(client,ComputationRound(),rounds_as_graphs)

    return (
        test_verification = test_verification,
        test_verification_verb = test_verification_verb,
        computation_verification = computation_verification,
        computation_verification_verb = computation_verification_verb,
        mode_outcome = mode_outcome)
end