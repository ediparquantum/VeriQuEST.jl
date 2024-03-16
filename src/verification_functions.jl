##################################################################
# Filename  : verification_functions.jl
# Author    : Jonathan Miller
# Date      : 2024-03-15
# Aim       : aim_script
#           : Verification functions
#           :
##################################################################



function is_round_OK(trap_results)
    # At least one trap result is 0 (failed)
    failed_traps = filter(x->x==0,trap_results)
    !(length(failed_traps) >= 1)
end

function compute_trap_round_fail_threshold(total_rounds,computational_rounds,number_different_test_rounds,inherent_bounded_error::InherentBoundedError) 
    t = total_rounds - computational_rounds #number of test rounds
    k,p = number_different_test_rounds,inherent_bounded_error.p
    floor((t/k)*(2*p - 1)/(2*p - 2))
end



function run_verification(::Client,::Server,
    round_types,client_resource,state_type)

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
        server_resource = create_resource(Server(),client_graph,client_qureg)
        server_quantum_state = server_resource["quantum_state"]
        num_qubits_from_server = server_quantum_state.numQubitsRepresented
        run_computation(Client(),Server(),client_meta_graph,num_qubits_from_server,server_quantum_state)
       
        initialise_blank_quantum_state!(server_quantum_state)

        push!(round_graphs,client_meta_graph)
    end

    round_graphs
end



function get_output(::Client,::Union{MBQC,ComputationRound},mg)
    output_inds = get_prop(mg,:output_inds)
    outcome = []
    for v in output_inds
            classic_outcome = get_prop(mg,v,:outcome)
            push!(outcome,classic_outcome)
    end
    outcome
end


function verify_round(::Client,::TestRound,mg)
    trap_results = []
    for v in vertices(mg)
        v_type = get_prop(mg,v,:vertex_type)
        if v_type isa TrapQubit
            neighs = all_neighbors(mg,v)
            bᵥ = get_prop(mg,v,:outcome)
            rᵥ = get_prop(mg,v,:one_time_pad_int)
            Dₙ = []
            for n in neighs
                dₙ = get_prop(mg,n,:init_qubit)
                push!(Dₙ,dₙ)
            end
            ver_res = mod(sum(reduce(vcat,[bᵥ,rᵥ,Dₙ])),2) == 0
            trap_res = ver_res ? TrapPass() : TrapFail()
            push!(trap_results,trap_res)
        end
    end
    # 1 the round is good, 0 the round is bad
    all([t isa TrapPass for t in trap_results]) ? 1 : 0
end



function verify_rounds(::Client,::TestRound,::Terse,rounds_as_graphs,pass_theshold)
      
    outcomes = []
    for mg in rounds_as_graphs
        get_prop(mg,:round_type) == ComputationRound() && continue
        push!(outcomes,verify_round(Client(),TestRound(),mg))
    end

    failed_rounds = count(==(0),outcomes)
    return failed_rounds > pass_theshold ? Abort() : Ok()
end


function verify_rounds(::Client,::TestRound,::Verbose,rounds_as_graphs,pass_theshold)
      
    outcomes = []
    for mg in rounds_as_graphs
        get_prop(mg,:round_type) == ComputationRound() && continue
        push!(outcomes,verify_round(Client(),TestRound(),mg))
    end
    num_rounds = length(outcomes)

    failed_rounds = count(==(0),outcomes)
    return (failed = failed_rounds,passed = num_rounds - failed_rounds)
end


function verify_rounds(::Client,::ComputationRound,::Terse,rounds_as_graphs)
    num_computation_rounds = [
        get_prop(mg,:round_type) == ComputationRound() ? 1 : nothing
            for mg in rounds_as_graphs] |>
        x-> filter(!isnothing,x) |>
        length
    
    outputs = []
    for mg in rounds_as_graphs
        get_prop(mg,:round_type) == TestRound() && continue
        push!(outputs,get_output(Client(),ComputationRound(),mg))
    end

    mod_res = mode(outputs)
    num_match_mode = count(==(mod_res),outputs)

    num_match_mode > num_computation_rounds/2 ? Ok() : Abort()
end

function verify_rounds(::Client,::ComputationRound,::Verbose,rounds_as_graphs)
    num_computation_rounds = [
        get_prop(mg,:round_type) == ComputationRound() ? 1 : nothing
            for mg in rounds_as_graphs] |>
        x-> filter(!isnothing,x) |>
        length
    
    outputs = []
    for mg in rounds_as_graphs
        get_prop(mg,:round_type) == TestRound() && continue
        push!(outputs,get_output(Client(),ComputationRound(),mg))
    end
    num_rounds = length(outputs)


    mod_res = mode(outputs)
    num_match_mode = count(==(mod_res),outputs)
    return (failed = num_rounds - num_match_mode, passed = num_match_mode)
end

function get_mode_output(::Client,::ComputationRound,rounds_as_graphs::Vector)

    outputs = []
    for mg in rounds_as_graphs
        get_prop(mg,:round_type) == TestRound() && continue
        push!(outputs,get_output(Client(),ComputationRound(),mg))
    end

   mode(outputs)
end


function get_ubqc_output(::Client,::ComputationRound,mg::MetaGraphs.MetaGraph)

        get_prop(mg,:round_type) == TestRound() && error("This function is for computational rounds only, not test rounds")
        get_output(Client(),ComputationRound(),mg)
end





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

    round_types = draw_random_rounds(para[:total_rounds],para[:computation_rounds])

    rounds_as_graphs = run_verification(
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


function run_verification_simulator(::TrustworthyServer,::Verbose,para)
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
        Client(),Server(),
        round_types,client_resource,
        para[:state_type])




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


function run_verification(client::Client,server::NoisyChannel,
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

function run_verification_simulator(server::NoisyChannel,::Terse,para)
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


function run_verification_simulator(server::NoisyChannel,::Verbose,para)
   
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

