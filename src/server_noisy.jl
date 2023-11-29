##################################################################
# Filename  : server_noisy.jl
# Author    : Jonathan Miller
# Date      : 2023-11-29
# Aim       : Making script to perform noisy operations

#           :
##################################################################
struct NoisyServer 
    noise_model::Union{Vector{NoiseModel},NoiseModel}
end


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

function add_noise!(
    ::Server,
    noise_model::NoiseModel)
    model = noise_model.model
    params = noise_model.params
    add_noise!(Server(),model,params)
end





function create_resource(server::NoisyServer,client_graph,client_qureg)
    # Server copies/clones data and structures
    server_graph = clone_graph(Server(),client_graph)
    server_env = create_quantum_env(Server())
    server_qureg = clone_qureq(Server(),client_qureg,server_env)
    noise_model = server.noise_model
    # Server adds noise
    !(noise_model isa Vector) && length(noise_model) == 1 && add_noise!(Server(),noise_model)
    (noise_model isa Vector) && length(noise_model) > 1 && add_noise!.(Ref(Server()),noise_model)

    #  Server entangles graph
    entangle_graph!(Server(),server_qureg,server_graph)
    return Dict("env"=>server_env,"quantum_state"=>server_qureg,"graph"=>server_graph)
end


function run_verification(::Client,server::NoisyServer,
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
        server_resource = create_resource(server,client_graph,client_qureg,malicious_angles)
        server_quantum_state = server_resource["quantum_state"]
        num_qubits_from_server = server_quantum_state.numQubitsRepresented
        run_computation(Client(),MaliciousServer(),server_resource,client_meta_graph,num_qubits_from_server,server_quantum_state)
       
        initialise_blank_quantum_state!(server_quantum_state)

        push!(round_graphs,client_meta_graph)
    end

    round_graphs
end