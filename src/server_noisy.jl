##################################################################
# Filename  : server_noisy.jl
# Author    : Jonathan Miller
# Date      : 2023-11-29
# Aim       : Making script to perform noisy operations

#           :
##################################################################


"""
    add_noise!(server::NoisyServer, server_qureg)

Adds noise to a quantum register (`server_qureg`) based on the noise model(s) defined in a `NoisyServer`. The function supports both single and multiple noise models. For each noise model, it retrieves the parameters using `get_noise_model_params` and applies the noise to each qubit in the quantum register.

# Arguments
- `server::NoisyServer`: A `NoisyServer` instance that contains the noise model(s) to be applied.
- `server_qureg`: The quantum register to which the noise will be applied.

# Examples
```julia    
server = NoisyServer(noise_model)
server_qureg = QuantumRegister(3)
add_noise!(server, server_qureg)
```
"""
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



"""
    create_resource(server::NoisyServer, client_graph, client_qureg)

Creates a resource for a `NoisyServer` by cloning the client's graph and quantum register, adding noise to the server's quantum register, and entangling the server's graph. Returns a dictionary containing the server's quantum environment, quantum state, and graph.

# Arguments
- `server::NoisyServer`: A `NoisyServer` instance to which the resource will be created.
- `client_graph`: The client's graph to be cloned.
- `client_qureg`: The client's quantum register to be cloned.

# Returns
- `Dict`: A dictionary containing the server's quantum environment (`"env"`), quantum state (`"quantum_state"`), and graph (`"graph"`).

# Examples
```julia    
server = NoisyServer(noise_model)
client_graph = create_graph(Client(), 3)
client_qureg = QuantumRegister(3)
resource = create_resource(server, client_graph, client_qureg)
```
"""
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


"""
    run_verification(client::Client, server::NoisyServer, round_types, client_resource, state_type)

Runs a verification process between a client and a noisy server. For each round type, it generates a property graph for the client, extracts the graph and quantum register from the client, creates resources for the server, runs the computation, initializes a blank quantum state for the server, and stores the client's meta graph. Returns a list of all client meta graphs.

# Arguments
- `client::Client`: A `Client` instance participating in the verification process.
- `server::NoisyServer`: A `NoisyServer` instance participating in the verification process.
- `round_types`: The types of rounds to be run in the verification process.
- `client_resource`: The resources available to the client.
- `state_type`: The type of state used in the verification process.

# Returns
- `Array`: An array of client meta graphs for each round type.

# Examples
```julia    
client = Client()
server = NoisyServer(noise_model)
round_types = [ComputationRound(), TestRound()]
client_resource = create_resource(client, client_graph, client_qureg)
state_type = :state1
round_graphs = run_verification(client, server, round_types, client_resource, state_type)
```
"""
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


"""
    run_verification_simulator(server::NoisyServer, ::Terse, para)

Runs a verification simulator on a `NoisyServer`. It defines colorings for computation and test rounds, computes the threshold for test rounds, creates a client resource, draws random rounds, runs the verification, verifies the rounds, and gets the mode outcome. Returns a tuple containing the results of the test verification, computation verification, and mode outcome.

# Arguments
- `server::NoisyServer`: A `NoisyServer` instance on which the verification simulator will be run.
- `::Terse`: A verbosity level for the verification process.
- `para`: A dictionary containing parameters for the verification process.

# Returns
- `Tuple`: A tuple containing the results of the test verification (`test_verification`), computation verification (`computation_verification`), and mode outcome (`mode_outcome`).

# Examples
```julia    
server = NoisyServer(noise_model)
para = Dict(:graph => create_graph(Client(), 3), :input => Dict(:indices => [1, 2], :values => [0, 1]), :output => [3], :secret_angles => [0.5, 0.5], :forward_flow => [0.5, 0.5], :total_rounds => 10, :computation_rounds => 5, :state_type => :state1)
results = run_verification_simulator(server, Terse(), para)
```
"""
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


"""
    run_verification_simulator(server::NoisyServer, ::Verbose, para)

Runs a verification simulator on a `NoisyServer` with verbose output. It defines colorings for computation and test rounds, computes the threshold for test rounds, creates a client resource, draws random rounds, runs the verification, verifies the rounds in both terse and verbose modes, and gets the mode outcome. Returns a tuple containing the results of the test verification, computation verification, verbose test verification, verbose computation verification, and mode outcome.

# Arguments
- `server::NoisyServer`: A `NoisyServer` instance on which the verification simulator will be run.
- `::Verbose`: A verbosity level for the verification process.
- `para`: A dictionary containing parameters for the verification process.

# Returns
- `Tuple`: A tuple containing the results of the test verification (`test_verification`), verbose test verification (`test_verification_verb`), computation verification (`computation_verification`), verbose computation verification (`computation_verification_verb`), and mode outcome (`mode_outcome`).

# Examples
```julia    
server = NoisyServer(noise_model)
para = Dict(:graph => create_graph(Client(), 3), :input => Dict(:indices => [1, 2], :values => [0, 1]), :output => [3], :secret_angles => [0.5, 0.5], :forward_flow => [0.5, 0.5], :total_rounds => 10, :computation_rounds => 5, :state_type => :state1)
results = run_verification_simulator(server, Verbose(), para)
```
"""
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