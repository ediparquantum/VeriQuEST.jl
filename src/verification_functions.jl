"""
    draw_random_rounds(total_rounds, computation_rounds)

Generates a random sequence of computation and test rounds. The function first calculates the number of test rounds by subtracting the number of computation rounds from the total rounds. It then creates arrays of `ComputationRound` and `TestRound` instances, and returns a shuffled concatenation of these arrays.

# Arguments
- `total_rounds`: The total number of rounds.
- `computation_rounds`: The number of computation rounds.

# Returns
- `Array`: A shuffled array of `ComputationRound` and `TestRound` instances.

# Examples
```julia    
total_rounds = 10
computation_rounds = 5
rounds = draw_random_rounds(total_rounds, computation_rounds)
```
"""
function draw_random_rounds(total_rounds,computation_rounds)
    test_rounds = total_rounds - computation_rounds
    crs = fill(ComputationRound(),computation_rounds)
    trs = fill(TestRound(),test_rounds)
    return shuffle(vcat(crs,trs))
end


"""
    is_round_OK(trap_results)

Checks if a round is successful by examining the trap results. The function filters out the trap results that are equal to 0 (indicating a failure), and checks if the length of the failed traps is less than 1. If there is at least one failed trap, the function returns `false`, indicating that the round is not OK.

# Arguments
- `trap_results`: An array of trap results.

# Returns
- `Bool`: `true` if the round is OK (no failed traps), `false` otherwise.

# Examples
```julia    
trap_results = [1, 0, 1]
round_OK = is_round_OK(trap_results)
```
"""
function is_round_OK(trap_results)
    # At least one trap result is 0 (failed)
    failed_traps = filter(x->x==0,trap_results)
    !(length(failed_traps) >= 1)
end


"""
    compute_trap_round_fail_threshold(total_rounds, computational_rounds, number_different_test_rounds, inherent_bounded_error::InherentBoundedError)

Computes the threshold for trap round failures. The function first calculates the number of test rounds by subtracting the number of computational rounds from the total rounds. It then uses this number, the number of different test rounds, and the inherent bounded error to calculate the threshold, which is then floored to the nearest integer.

# Arguments
- `total_rounds`: The total number of rounds.
- `computational_rounds`: The number of computational rounds.
- `number_different_test_rounds`: The number of different test rounds.
- `inherent_bounded_error::InherentBoundedError`: An instance of `InherentBoundedError` representing the inherent bounded error.

# Returns
- `Int`: The floored threshold for trap round failures.

# Examples
```julia    
total_rounds = 10
computational_rounds = 5
number_different_test_rounds = 3
inherent_bounded_error = InherentBoundedError(0.33)
threshold = compute_trap_round_fail_threshold(total_rounds, computational_rounds, number_different_test_rounds, inherent_bounded_error)
```
"""
function compute_trap_round_fail_threshold(total_rounds,computational_rounds,number_different_test_rounds,inherent_bounded_error::InherentBoundedError) 
    t = total_rounds - computational_rounds #number of test rounds
    k,p = number_different_test_rounds,inherent_bounded_error.p
    floor((t/k)*(2*p - 1)/(2*p - 2))
end


"""
    run_computation(client::Client, server::Union{Server,NoisyServer}, client_meta_graph, num_qubits_from_server, server_quantum_state)

Runs a computation on a server from a client's perspective. The function iterates over the number of qubits from the server, updates the client's ϕ, measures along the ϕ basis on the server, updates the measurement on the client, and stores the measurement outcome on the client. The updated client meta graph is returned.

# Arguments
- `client::Client`: A `Client` instance.
- `server::Union{Server,NoisyServer}`: A `Server` or `NoisyServer` instance.
- `client_meta_graph`: The client's meta graph.
- `num_qubits_from_server`: The number of qubits from the server.
- `server_quantum_state`: The quantum state of the server.

# Returns
- `client_meta_graph`: The updated client meta graph.

# Examples
```julia    
client = Client()
server = NoisyServer(noise_model)
client_meta_graph = create_graph(client, 3)
num_qubits_from_server = 3
server_quantum_state = create_quantum_state(server, num_qubits_from_server)
updated_client_meta_graph = run_computation(client, server, client_meta_graph, num_qubits_from_server, server_quantum_state)
```
"""
function run_computation(client::Client,server::Union{Server,NoisyServer},client_meta_graph,num_qubits_from_server,server_quantum_state)
    for q in Base.OneTo(num_qubits_from_server)  
        ϕ = get_updated_ϕ!(client,client_meta_graph,q)
        m̃ = measure_along_ϕ_basis!(server,server_quantum_state,q,ϕ)
        m = update_measurement(client,q,client_meta_graph,m̃)
        store_measurement_outcome!(client,client_meta_graph,q,m)
    end
    client_meta_graph
end



"""
    run_computation(client_meta_graph, num_qubits_from_server, server_quantum_state)

Runs a computation by creating a new `Client` instance for each qubit from the server. The function iterates over the number of qubits from the server, updates the client's ϕ, measures along the ϕ basis on the client, updates the measurement on the client, and stores the measurement outcome on the client. The updated client meta graph is returned.

# Arguments
- `client_meta_graph`: The client's meta graph.
- `num_qubits_from_server`: The number of qubits from the server.
- `server_quantum_state`: The quantum state of the server.

# Returns
- `client_meta_graph`: The updated client meta graph.

# Examples
```julia    
client_meta_graph = create_graph(Client(), 3)
num_qubits_from_server = 3
server_quantum_state = create_quantum_state(Client(), num_qubits_from_server)
updated_client_meta_graph = run_computation(client_meta_graph, num_qubits_from_server, server_quantum_state)
```
"""
function run_computation(client_meta_graph,num_qubits_from_server,server_quantum_state)
    for q in Base.OneTo(num_qubits_from_server)  
        ϕ = get_updated_ϕ!(Client(),client_meta_graph,q)
        m̃ = measure_along_ϕ_basis!(Client(),server_quantum_state,q,ϕ)
        m = update_measurement(Client(),q,client_meta_graph,m̃)
        store_measurement_outcome!(Client(),client_meta_graph,q,m)
    end
    client_meta_graph
end


"""
    run_verification(::Client, ::Server, round_types, client_resource, state_type)

Runs a verification process between a client and a server. For each round type, the function generates a client meta graph, extracts the graph and quantum register (qureg) from the client, creates server resources, runs a computation, initializes a blank quantum state on the server, and stores the client meta graph in a list. The list of client meta graphs is returned.

# Arguments
- `::Client`: A `Client` instance.
- `::Server`: A `Server` instance.
- `round_types`: The types of rounds to run.
- `client_resource`: The client's resources.
- `state_type`: The type of state.

# Returns
- `Array`: An array of client meta graphs.

# Examples
```julia    
round_types = ["round1", "round2"]
client_resource = create_resource(Client())
state_type = "state_type_example"
round_graphs = run_verification(Client(), Server(), round_types, client_resource, state_type)
```
"""
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



"""
    get_output(::Client, ::Union{MBQC,ComputationRound}, mg)

Retrieves the output of a computation from a client's meta graph. The function gets the output indices from the meta graph, iterates over them, gets the outcome for each index, and stores the outcomes in a list. The list of outcomes is returned.

# Arguments
- `::Client`: A `Client` instance.
- `::Union{MBQC,ComputationRound}`: An instance of `MBQC` or `ComputationRound`.
- `mg`: The client's meta graph.

# Returns
- `Array`: An array of outcomes.

# Examples
```julia    
mg = create_meta_graph(Client())
outcomes = get_output(Client(), ComputationRound(), mg)
```
"""
function get_output(::Client,::Union{MBQC,ComputationRound},mg)
    output_inds = get_prop(mg,:output_inds)
    outcome = []
    for v in output_inds
            classic_outcome = get_prop(mg,v,:outcome)
            push!(outcome,classic_outcome)
    end
    outcome
end




"""
    verify_round(::Client, ::TestRound, mg)

Verifies a round of computation from a client's meta graph. The function iterates over the vertices of the meta graph, checks if the vertex type is a `TrapQubit`, gets the neighbors and properties of the vertex, calculates the verification result, and stores the result in a list. If all results are `TrapPass`, the function returns 1 (indicating the round is good); otherwise, it returns 0 (indicating the round is bad).

# Arguments
- `::Client`: A `Client` instance.
- `::TestRound`: A `TestRound` instance.
- `mg`: The client's meta graph.

# Returns
- `Int`: 1 if the round is good, 0 if the round is bad.

# Examples
```julia    
mg = create_meta_graph(Client())
round_verification = verify_round(Client(), TestRound(), mg)
```
"""
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



"""
    verify_rounds(::Client, ::TestRound, ::Terse, rounds_as_graphs, pass_threshold)

Verifies multiple rounds of computation from a list of client's meta graphs. The function iterates over the meta graphs, skips those with a round type of `ComputationRound`, verifies the round, and stores the outcome in a list. The function then counts the number of failed rounds. If the number of failed rounds is greater than the pass threshold, the function returns `Abort()`, otherwise it returns `Ok()`.

# Arguments
- `::Client`: A `Client` instance.
- `::TestRound`: A `TestRound` instance.
- `::Terse`: A `Terse` instance.
- `rounds_as_graphs`: A list of client's meta graphs.
- `pass_threshold`: The threshold for a round to be considered as passed.

# Returns
- `Abort` or `Ok`: `Abort()` if the number of failed rounds is greater than the pass threshold, `Ok()` otherwise.

# Examples
```julia    
rounds_as_graphs = [create_meta_graph(Client()) for _ in 1:5]
pass_threshold = 3
round_verification = verify_rounds(Client(), TestRound(), Terse(), rounds_as_graphs, pass_threshold)
```
"""
function verify_rounds(::Client,::TestRound,::Terse,rounds_as_graphs,pass_theshold)
      
    outcomes = []
    for mg in rounds_as_graphs
        get_prop(mg,:round_type) == ComputationRound() && continue
        push!(outcomes,verify_round(Client(),TestRound(),mg))
    end

    failed_rounds = count(==(0),outcomes)
    return failed_rounds > pass_theshold ? Abort() : Ok()
end


"""
    verify_rounds(::Client, ::TestRound, ::Verbose, rounds_as_graphs, pass_threshold)

Verifies multiple rounds of computation from a list of client's meta graphs. The function iterates over the meta graphs, skips those with a round type of `ComputationRound`, verifies the round, and stores the outcome in a list. The function then counts the number of failed rounds and returns a tuple with the number of failed and passed rounds.

# Arguments
- `::Client`: A `Client` instance.
- `::TestRound`: A `TestRound` instance.
- `::Verbose`: A `Verbose` instance.
- `rounds_as_graphs`: A list of client's meta graphs.
- `pass_threshold`: The threshold for a round to be considered as passed.

# Returns
- `Tuple`: A tuple with the number of failed and passed rounds.

# Examples
```julia    
rounds_as_graphs = [create_meta_graph(Client()) for _ in 1:5]
pass_threshold = 3
round_verification = verify_rounds(Client(), TestRound(), Verbose(), rounds_as_graphs, pass_threshold)
```
"""
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


"""
    verify_rounds(::Client, ::ComputationRound, ::Terse, rounds_as_graphs)

Verifies multiple rounds of computation from a list of client's meta graphs. The function counts the number of computation rounds, collects the outputs of the computation rounds, calculates the mode of the outputs, and counts the number of outputs that match the mode. If the number of outputs that match the mode is greater than half the number of computation rounds, the function returns `Ok()`, otherwise it returns `Abort()`.

# Arguments
- `::Client`: A `Client` instance.
- `::ComputationRound`: A `ComputationRound` instance.
- `::Terse`: A `Terse` instance.
- `rounds_as_graphs`: A list of client's meta graphs.

# Returns
- `Ok` or `Abort`: `Ok()` if the number of outputs that match the mode is greater than half the number of computation rounds, `Abort()` otherwise.

# Examples
```julia    
rounds_as_graphs = [create_meta_graph(Client()) for _ in 1:5]
round_verification = verify_rounds(Client(), ComputationRound(), Terse(), rounds_as_graphs)
```
"""
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

"""
    verify_rounds(::Client, ::ComputationRound, ::Verbose, rounds_as_graphs)

Verifies multiple rounds of computation from a list of client's meta graphs. The function counts the number of computation rounds, collects the outputs of the computation rounds, calculates the mode of the outputs, and counts the number of outputs that match the mode. The function then returns a tuple with the number of failed and passed rounds.

# Arguments
- `::Client`: A `Client` instance.
- `::ComputationRound`: A `ComputationRound` instance.
- `::Verbose`: A `Verbose` instance.
- `rounds_as_graphs`: A list of client's meta graphs.

# Returns
- `Tuple`: A tuple with the number of failed and passed rounds.

# Examples
```julia    
rounds_as_graphs = [create_meta_graph(Client()) for _ in 1:5]
round_verification = verify_rounds(Client(), ComputationRound(), Verbose(), rounds_as_graphs)
```
"""
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


"""
    get_mode_output(::Client, ::ComputationRound, rounds_as_graphs::Vector)

Collects the outputs of computation rounds from a list of client's meta graphs and returns the mode of the outputs. The function iterates over the meta graphs, skips those with a round type of `TestRound`, gets the output of the computation round, and stores it in a list. The function then calculates and returns the mode of the outputs.

# Arguments
- `::Client`: A `Client` instance.
- `::ComputationRound`: A `ComputationRound` instance.
- `rounds_as_graphs::Vector`: A list of client's meta graphs.

# Returns
- `mode(outputs)`: The mode of the outputs.

# Examples
```julia    
rounds_as_graphs = [create_meta_graph(Client()) for _ in 1:5]
mode_output = get_mode_output(Client(), ComputationRound(), rounds_as_graphs)
```
"""
function get_mode_output(::Client,::ComputationRound,rounds_as_graphs::Vector)

    outputs = []
    for mg in rounds_as_graphs
        get_prop(mg,:round_type) == TestRound() && continue
        push!(outputs,get_output(Client(),ComputationRound(),mg))
    end

   mode(outputs)
end


"""
    get_ubqc_output(::Client, ::ComputationRound, mg::MetaGraphs.MetaGraph)

Gets the output of a computation round from a client's meta graph. The function checks if the round type of the meta graph is `TestRound`, and if so, it throws an error. Otherwise, it gets and returns the output of the computation round.

# Arguments
- `::Client`: A `Client` instance.
- `::ComputationRound`: A `ComputationRound` instance.
- `mg::MetaGraphs.MetaGraph`: A client's meta graph.

# Returns
- The output of the computation round.

# Errors
- Throws an error if the round type of the meta graph is `TestRound`.

# Examples
```julia    
ubqc_output = get_ubqc_output(Client(), ComputationRound(), mg)
```
"""
function get_ubqc_output(::Client,::ComputationRound,mg::MetaGraphs.MetaGraph)

        get_prop(mg,:round_type) == TestRound() && error("This function is for computational rounds only, not test rounds")
        get_output(Client(),ComputationRound(),mg)
end


"""
    create_ubqc_resource(para)

Creates a UBQC (Universal Blind Quantum Computation) resource using the provided parameters. The function initializes the test and computation colours, computes the backward flow, and creates a dictionary with the parameters. It then calls the `create_graph_resource` function with the created dictionary as an argument.

# Arguments
- `para`: A dictionary containing the parameters for the UBQC resource. It should include the following keys: `:input`, `:output`, `:graph`, `:secret_angles`, and `:forward_flow`.

# Returns
- The result of the `create_graph_resource` function.

# Examples
```julia    
para = (args)::NamedTuple # function specific args
ubqc_resource = create_ubqc_resource(para)
```
"""
function create_ubqc_resource(para)
    
    test_colours = []#get_vector_graph_colors(para[:graph];reps=reps)
    computation_colours = ones(nv(para[:graph]))
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
     
    create_graph_resource(p)
end


"""
    run_ubqc(para)

Runs a Universal Blind Quantum Computation (UBQC) using the provided parameters. The function creates a UBQC resource, generates a client meta graph, extracts the graph and quantum register (qureg) from the client, creates server resources, runs the computation, and gets the UBQC output.

# Arguments
- `para`: A dictionary containing the parameters for the UBQC. It should include the key `:state_type`.

# Returns
- The output of the UBQC, obtained by calling `get_ubqc_output`.

# Examples
```julia    
para = (args)::NamedTuple # function specific args
ubqc_output = run_ubqc(para)
```
"""
function run_ubqc(para)
    
   state_type = para[:state_type]
   client_resource = create_ubqc_resource(para)

    # Generate client meta graph
    client_meta_graph = generate_property_graph!(
       Client(),
       ComputationRound(),
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
   #initialise_blank_quantum_state!(server_quantum_state)
   return get_ubqc_output(Client(),ComputationRound(),client_meta_graph)
end

"""
    run_mbqc(para)

Runs a Measurement-Based Quantum Computation (MBQC) using the provided parameters. The function creates a UBQC resource, generates a client meta graph, extracts the quantum state from the client meta graph, runs the computation, and gets the output.

# Arguments
- `para`: A dictionary containing the parameters for the MBQC. It should include the key `:state_type`.

# Returns
- The output of the MBQC, obtained by calling `get_output`.

# Examples
```julia    
para = (args)::NamedTuple # function specific args
mbqc_output = run_mbqc(para)
```
"""
function run_mbqc(para)
    resource = create_ubqc_resource(para)
    client_meta_graph = generate_property_graph!(
        Client(),MBQC(),resource,para[:state_type])
    quantum_state = get_prop(client_meta_graph,:quantum_state)
    num_qubits = quantum_state.numQubitsRepresented
    run_computation(client_meta_graph,num_qubits,quantum_state)
    get_output(Client(),MBQC(),client_meta_graph)
end


"""
    run_verification_simulator(::TrustworthyServer, ::Terse, para)

Runs a verification simulator for a TrustworthyServer in a Terse mode. The function defines colouring, computes the backward flow, creates a client resource, draws random rounds, runs the verification, verifies the rounds, gets the mode output, and returns the verification results and mode outcome.

# Arguments
- `::TrustworthyServer`: An instance of `TrustworthyServer`.
- `::Terse`: An instance of `Terse`.
- `para`: A dictionary containing the parameters for the verification simulator. It should include the keys `:graph`, `:input`, `:output`, `:secret_angles`, `:forward_flow`, `:total_rounds`, and `:computation_rounds`.

# Returns
- A tuple containing the test verification result, the computation verification result, and the mode outcome.

# Examples
```julia    
para = (args)::NamedTuple # function specific args
result = run_verification_simulator(TrustworthyServer(), Terse(), para)
```
"""
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


"""
    run_mbqc(para)

Runs a Measurement-Based Quantum Computation (MBQC) using the provided parameters. The function creates a UBQC resource, generates a client meta graph, extracts the quantum state from the client meta graph, runs the computation, and gets the output.

# Arguments
- `para`: A NamedTuple containing the parameters for the MBQC.

# Returns
- The output of the MBQC, obtained by calling `get_output`.

# Examples
```julia    
para = (args)::NamedTuple # function specific args
mbqc_output = run_mbqc(para)
```
"""
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
