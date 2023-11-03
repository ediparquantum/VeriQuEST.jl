# Permute rounds to be test of computation
function draw_random_rounds(total_rounds,computation_rounds)
    test_rounds = total_rounds - computation_rounds
    crs = fill(ComputationRound(),computation_rounds)
    trs = fill(TestRound(),test_rounds)
    return shuffle(vcat(crs,trs))
end



function is_round_OK(trap_results)
    # At least one trap result is 0 (failed)
    failed_traps = filter(x->x==0,trap_results)
    !(length(failed_traps) >= 1)
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

        
        for q in Base.OneTo(num_qubits_from_server)  
            ϕ = get_updated_ϕ!(Client(),client_meta_graph,q)
            m̃ = measure_along_ϕ_basis!(Server(),server_quantum_state,q,ϕ)
            m = update_measurement(Client(),q,client_meta_graph,m̃)
            store_measurement_outcome!(Client(),client_meta_graph,q,m)
        end
            
        initialise_blank_quantum_state!(server_quantum_state)

        push!(round_graphs,client_meta_graph)
    end

    round_graphs
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

function verify_rounds(::Client,::TestRound,rounds_as_graphs,pass_theshold)
      
    outcomes = []
    for mg in rounds_as_graphs
        get_prop(mg,:round_type) == ComputationRound() && continue
        push!(outcomes,verify_round(Client(),TestRound(),mg))
    end

    failed_rounds = count(==(0),outcomes)
    return failed_rounds > pass_theshold ? Abort() : Ok()
end

function get_output(::Client,::ComputationRound,mg)
    output_inds = get_prop(mg,:output_inds)
    outcome = []
    for v in output_inds
            classic_outcome = get_prop(mg,v,:outcome)
            push!(outcome,classic_outcome)
    end
    outcome
end

function verify_rounds(::Client,::ComputationRound,rounds_as_graphs)
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
