##################################################################
# Filename  : server_malicious_behaviour.jl
# Author    : Jonathan Miller
# Date      : 2024-02-12
# Aim       : aim_script
#           : Functions for the "server" in the client-server model
#           : with malicious behaviour
#           : This could be its own module
##################################################################


"""
    MaliciousServer

A type representing a server that is malicious. This type is used to model a server that
behaves in a way that is not consistent with the protocol. This type is used to model
malicious behaviour in the client-server model.

# Examples
```julia
MaliciousServer()
```
"""
struct MaliciousServer end




"""
    get_updated_ϕ!(::MaliciousServer, server_resource, qubit, ϕ::Float64)

Updates the phase angle for a given qubit in a malicious server context.

# Arguments
- `::MaliciousServer`: Indicates that this function is used in the context of a malicious server.
- `server_resource::Dict`: A dictionary containing server resources.
- `qubit::Int64`: The qubit for which the phase angle is to be updated.
- `ϕ::Float64`: The current phase angle.

# Returns
- `Float64`: The updated phase angle.
"""
function get_updated_ϕ!(::MaliciousServer,server_resource,qubit,ϕ::Float64)
    angles = server_resource["angles"]
    θ = length(angles) > 1 ? angles[qubit] : angles[1]
    θ + ϕ
end


"""
    measure_along_ϕ_basis!(::MaliciousServer, ψ, v::Union{Int32,Int64}, ϕ::Float64)

Performs a measurement on a qubit along a specified phase basis in a malicious server context.

# Arguments
- `::MaliciousServer`: Indicates that this function is used in the context of a malicious server.
- `ψ::QuEST object`: The quantum state to be measured.
- `v::Union{Int32,Int64}`: The qubit to be measured.
- `ϕ::Float64`: The phase angle defining the basis for measurement.

# Examples
```julia    
ψ = createQureg(1, createQuESTEnv())
v = 1
ϕ = π/4
measure_along_ϕ_basis!(MaliciousServer(), ψ, v, ϕ)
```
"""
function measure_along_ϕ_basis!(::MaliciousServer,ψ,v::Union{Int32,Int64},ϕ::Float64)
    rotateZ(ψ,v,-ϕ)
    hadamard(ψ,v)
    measure(ψ,v)
end



"""
    create_resource(::MaliciousServer, client_graph, client_qureg, malicious_angles::Union{Float64,Vector{Float64}})

Creates a resource dictionary for a malicious server, including a cloned graph, a quantum environment, a quantum register, and a set of malicious angles.

# Arguments
- `::MaliciousServer`: Indicates that this function is used in the context of a malicious server.
- `client_graph::Graph`: The client's graph to be cloned.
- `client_qureg::QuEST object`: The client's quantum register to be cloned.
- `malicious_angles::Union{Float64,Vector{Float64}}`: The angles to be used for malicious behavior.

# Examples
```julia    
client_graph = create_graph(Client(), 3)
client_qureg = create_qureg(Client(), 3)
malicious_angles = [π/4, π/2, 3π/4]
create_resource(MaliciousServer(), client_graph, client_qureg, malicious_angles)
```
"""
function create_resource(::MaliciousServer,client_graph,client_qureg,malicious_angles::Union{Float64,Vector{Float64}})
    # Server copies/clones data and structures
    server_graph = clone_graph(Server(),client_graph)
    server_env = create_quantum_env(Server())
    server_qureg = clone_qureq(Server(),client_qureg,server_env)

    #  Server entangles graph
    entangle_graph!(Server(),server_qureg,server_graph)
    return Dict("env"=>server_env,"quantum_state"=>server_qureg,"graph"=>server_graph, "angles" => malicious_angles)
end



"""
    run_computation(::Client, ::MaliciousServer, server_resource, client_meta_graph, num_qubits_from_server, server_quantum_state)

Runs a quantum computation in the context of a client interacting with a malicious server. The computation involves updating phase angles, measuring along a specific basis, and storing the measurement outcomes.

# Arguments
- `::Client`: Indicates that this function is used in the context of a client.
- `::MaliciousServer`: Indicates that this function is used in the context of a malicious server.
- `server_resource::Dict`: A dictionary containing server resources.
- `client_meta_graph::Graph`: The client's meta graph.
- `num_qubits_from_server::Int64`: The number of qubits received from the server.
- `server_quantum_state::QuEST object`: The server's quantum state.

# Examples
```julia    
server_resource = Dict("env" => create_quantum_env(Server()), "quantum_state" => create_qureg(Server(), 3), "graph" => create_graph(Server(), 3), "angles" => [π/4, π/2, 3π/4])
client_meta_graph = create_graph(Client(), 3)
num_qubits_from_server = 3
server_quantum_state = create_qureg(Server(), 3)
run_computation(Client(), MaliciousServer(), server_resource, client_meta_graph, num_qubits_from_server, server_quantum_state)
```
"""
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


"""
    run_verification(::Client, ::MaliciousServer, round_types, client_resource, state_type, malicious_angles)

Runs a verification process in the context of a client interacting with a malicious server. The process involves generating a property graph, initializing a graph and a quantum register, creating server resources, running a computation, and initializing a blank quantum state.

# Arguments
- `::Client`: Indicates that this function is used in the context of a client.
- `::MaliciousServer`: Indicates that this function is used in the context of a malicious server.
- `round_types::Array`: An array of round types.
- `client_resource::Dict`: A dictionary containing client resources.
- `state_type::Symbol`: The type of the quantum state.
- `malicious_angles::Union{Float64,Vector{Float64}}`: The angles to be used for malicious behavior.

# Examples
```julia    
round_types = [:round1, :round2, :round3]
client_resource = Dict("env" => create_quantum_env(Client()), "quantum_state" => create_qureg(Client(), 3), "graph" => create_graph(Client(), 3))
state_type = :state1
malicious_angles = [π/4, π/2, 3π/4]
run_verification(Client(), MaliciousServer(), round_types, client_resource, state_type, malicious_angles)
```
"""
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


"""
    run_verification_simulator(::MaliciousServer, ::Terse, para, malicious_angles)

Runs a verification simulator in the context of a malicious server. The simulator involves defining colouring, computing backward flow, creating a graph resource, drawing random rounds, running verification, verifying rounds, and getting mode output.

# Arguments
- `::MaliciousServer`: Indicates that this function is used in the context of a malicious server.
- `::Terse`: Indicates that this function is used in a terse mode.
- `para::Dict`: A dictionary containing parameters for the simulation.
- `malicious_angles::Union{Float64,Vector{Float64}}`: The angles to be used for malicious behavior.

# Examples
```julia    
para = Dict("input" => Dict("indices" => [1, 2, 3], "values" => [0.5, 0.5, 0.5]), "output" => [4, 5, 6], "graph" => create_graph(Client(), 3), "secret_angles" => [π/4, π/2, 3π/4], "forward_flow" => [0.1, 0.2, 0.3], "total_rounds" => 10, "computation_rounds" => 5, "state_type" => :state1)
malicious_angles = [π/4, π/2, 3π/4]
run_verification_simulator(MaliciousServer(), Terse(), para, malicious_angles)
```
"""
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

"""
    run_verification_simulator(::MaliciousServer, ::Verbose, para, malicious_angles)

Runs a verification simulator in the context of a malicious server. The simulator involves defining colouring, computing backward flow, creating a graph resource, drawing random rounds, running verification, verifying rounds in both terse and verbose modes, and getting mode output.

# Arguments
- `::MaliciousServer`: Indicates that this function is used in the context of a malicious server.
- `::Verbose`: Indicates that this function is used in a verbose mode.
- `para::Dict`: A dictionary containing parameters for the simulation.
- `malicious_angles::Union{Float64,Vector{Float64}}`: The angles to be used for malicious behavior.

# Examples
```julia    
para = Dict("input" => Dict("indices" => [1, 2, 3], "values" => [0.5, 0.5, 0.5]), "output" => [4, 5, 6], "graph" => create_graph(Client(), 3), "secret_angles" => [π/4, π/2, 3π/4], "forward_flow" => [0.1, 0.2, 0.3], "total_rounds" => 10, "computation_rounds" => 5, "state_type" => :state1)
malicious_angles = [π/4, π/2, 3π/4]
run_verification_simulator(MaliciousServer(), Verbose(), para, malicious_angles)
```
"""
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

