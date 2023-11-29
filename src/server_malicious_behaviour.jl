struct MaliciousServer end





function get_updated_ϕ!(::MaliciousServer,server_resource,qubit,ϕ::qreal)
    angles = server_resource["angles"]
    θ = length(angles) > 1 ? angles[qubit] : angles[1]
    θ + ϕ
end

function measure_along_ϕ_basis!(::MaliciousServer,ψ,v::Union{Int32,Int64},ϕ::qreal)
    v = c_shift_index(v)
    QuEST.rotateZ(ψ,v,-ϕ)
    QuEST.hadamard(ψ,v)
    QuEST.measure(ψ,v)
end

function create_resource(::MaliciousServer,client_graph,client_qureg,malicious_angles::Union{Float64,Vector{Float64}})
    # Server copies/clones data and structures
    server_graph = clone_graph(Server(),client_graph)
    server_env = create_quantum_env(Server())
    server_qureg = clone_qureq(Server(),client_qureg,server_env)

    #  Server entangles graph
    entangle_graph!(Server(),server_qureg,server_graph)
    return Dict("env"=>server_env,"quantum_state"=>server_qureg,"graph"=>server_graph, "angles" => malicious_angles)
end

function run_computation(::Client,::MaliciousServer,server_resource,client_meta_graph,num_qubits_from_server,server_quantum_state)
    for q in Base.OneTo(num_qubits_from_server)  
        ϕ̃ = get_updated_ϕ!(Client(),client_meta_graph,q)
        ϕ = get_updated_ϕ!(MaliciousServer(),server_resource,q,ϕ̃)
        m̃ = measure_along_ϕ_basis!(MaliciousServer(),server_quantum_state,q,ϕ)
        m = update_measurement(Client(),q,client_meta_graph,m̃)
        store_measurement_outcome!(Client(),client_meta_graph,q,m)
    end
    client_meta_graph
end

function run_verification(::Client,::MaliciousServer,
    round_types,client_resource,state_type,malicious_angles)

    round_graphs = []
    for round_type in round_types
        
        # Generate client meta graph
        client_meta_graph = generate_property_graph!(
            Client(),
            round_type,
            client_resource,
            state_type)
        

        # Extract graph and qureg from client
        client_graph = produce_initialised_graph(Client(),client_meta_graph)
        client_qureg = produce_initialised_qureg(Client(),client_meta_graph)
        
        # Create server resources
        server_resource = create_resource(MaliciousServer(),client_graph,client_qureg,malicious_angles)
        server_quantum_state = server_resource["quantum_state"]
        num_qubits_from_server = server_quantum_state.numQubitsRepresented
        run_computation(Client(),MaliciousServer(),server_resource,client_meta_graph,num_qubits_from_server,server_quantum_state)
       
        initialise_blank_quantum_state!(server_quantum_state)

        push!(round_graphs,client_meta_graph)
    end

    round_graphs
end



function run_verification_simulator(::MaliciousServer,::Terse,para,malicious_angles)
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
        Client(),MaliciousServer(),
        round_types,client_resource,
        para[:state_type],malicious_angles)


        test_verification = verify_rounds(Client(),TestRound(),Terse(),rounds_as_graphs,test_rounds_theshold)
        computation_verification = verify_rounds(Client(),ComputationRound(),Terse(),rounds_as_graphs)
        mode_outcome = get_mode_output(Client(),ComputationRound(),rounds_as_graphs)
    return (
        test_verification = test_verification,
        computation_verification = computation_verification,
        mode_outcome = mode_outcome)
end


function run_verification_simulator(::MaliciousServer,::Verbose,para,malicious_angles)
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
        Client(),MaliciousServer(),
        round_types,client_resource,
        para[:state_type],malicious_angles)


        test_verification = verify_rounds(Client(),TestRound(),Terse(),rounds_as_graphs,test_rounds_theshold)
        computation_verification = verify_rounds(Client(),ComputationRound(),Terse(),rounds_as_graphs)
        test_verification_verb = verify_rounds(Client(),TestRound(),Verbose(),rounds_as_graphs,test_rounds_theshold)
        computation_verification_verb = verify_rounds(Client(),ComputationRound(),Verbose(),rounds_as_graphs)
        mode_outcome = get_mode_output(Client(),ComputationRound(),rounds_as_graphs)
    return (
        test_verification = test_verification,
        test_verification_verb = test_verification_verb,
        computation_verification = computation_verification,
        computation_verification_verb = computation_verification_verb,
        mode_outcome = mode_outcome)
end

