##################################################################
# Filename  : run_quantum_computation.jl
# Author    : Jonathan Miller
# Date      : 2024-03-13
# Aim       : aim_script
#           : Run quantum computation scripts
#           :
##################################################################




function create_resource(server::NoisyChannel,client_graph,client_qureg)
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



function create_resource(::MaliciousServer,client_graph,client_qureg,malicious_angles::Union{Float64,Vector{Float64}})
    # Server copies/clones data and structures
    server_graph = clone_graph(Server(),client_graph)
    server_env = create_quantum_env(Server())
    server_qureg = clone_qureq(Server(),client_qureg,server_env)

    #  Server entangles graph
    entangle_graph!(Server(),server_qureg,server_graph)
    return Dict("env"=>server_env,"quantum_state"=>server_qureg,"graph"=>server_graph, "angles" => malicious_angles)
end





function create_resource(::Server,client_graph,client_qureg)
    # Server copies/clones data and structures
    server_graph = clone_graph(Server(),client_graph)
    server_env = create_quantum_env(Server())
    server_qureg = clone_qureq(Server(),client_qureg,server_env)

    #  Server entangles graph
    entangle_graph!(Server(),server_qureg,server_graph)
    return Dict("env"=>server_env,"quantum_state"=>server_qureg,"graph"=>server_graph)
end



# set up quantum state
  # set up network emulation
  # run computation which is dependent on the network emulation

  # range of qubits in server
  # provide first basis angle to server
  # measure along basis 
  # update measurement_angle
  # store measurement
  # return metagraph



    for q in Base.OneTo(num_qubits_from_server)  
        ϕ = get_updated_ϕ!(Client(),client_meta_graph,q)
        m̃ = measure_along_ϕ_basis!(Client(),server_quantum_state,q,ϕ)
        m = update_measurement(Client(),q,client_meta_graph,m̃)
        store_measurement_outcome!(Client(),client_meta_graph,q,m)
    end
    client_meta_graph
end



  function run_computation(client_meta_graph,num_qubits_from_server,server_quantum_state)
    for q in Base.OneTo(num_qubits_from_server)  
        ϕ = get_updated_ϕ!(Client(),client_meta_graph,q)
        m̃ = measure_along_ϕ_basis!(Client(),server_quantum_state,q,ϕ)
        m = update_measurement(Client(),q,client_meta_graph,m̃)
        store_measurement_outcome!(Client(),client_meta_graph,q,m)
    end
    client_meta_graph
end

  function run_computation(client::Client,server::Union{Server,NoisyChannel},client_meta_graph,num_qubits_from_server,server_quantum_state)
    for q in Base.OneTo(num_qubits_from_server)  
        ϕ = get_updated_ϕ!(client,client_meta_graph,q)
        m̃ = measure_along_ϕ_basis!(server,server_quantum_state,q,ϕ)
        m = update_measurement(client,q,client_meta_graph,m̃)
        store_measurement_outcome!(client,client_meta_graph,q,m)
    end
    client_meta_graph
end




function run_computation(client::Client,server::Union{Server,NoisyChannel},client_meta_graph,num_qubits_from_server,server_quantum_state)
    for q in Base.OneTo(num_qubits_from_server)  
        ϕ = get_updated_ϕ!(client,client_meta_graph,q)
        m̃ = measure_along_ϕ_basis!(server,server_quantum_state,q,ϕ)
        m = update_measurement(client,q,client_meta_graph,m̃)
        store_measurement_outcome!(client,client_meta_graph,q,m)
    end
    client_meta_graph
end




function run_computation(client_meta_graph,num_qubits_from_server,server_quantum_state)
    for q in Base.OneTo(num_qubits_from_server)  
        ϕ = get_updated_ϕ!(Client(),client_meta_graph,q)
        m̃ = measure_along_ϕ_basis!(Client(),server_quantum_state,q,ϕ)
        m = update_measurement(Client(),q,client_meta_graph,m̃)
        store_measurement_outcome!(Client(),client_meta_graph,q,m)
    end
    client_meta_graph
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


function run_mbqc(para)
    resource = create_ubqc_resource(para)
    client_meta_graph = generate_property_graph!(
        Client(),MBQC(),resource,para[:state_type])
    quantum_state = get_prop(client_meta_graph,:quantum_state)
    num_qubits = quantum_state.numQubitsRepresented
    run_computation(client_meta_graph,num_qubits,quantum_state)
    get_output(Client(),MBQC(),client_meta_graph)
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


  function run_computation(client::Client,server::Union{Server,NoisyChannel},client_meta_graph,num_qubits_from_server,server_quantum_state)
    for q in Base.OneTo(num_qubits_from_server)  
        ϕ = get_updated_ϕ!(client,client_meta_graph,q)
        m̃ = measure_along_ϕ_basis!(server,server_quantum_state,q,ϕ)
        m = update_measurement(client,q,client_meta_graph,m̃)
        store_measurement_outcome!(client,client_meta_graph,q,m)
    end
    client_meta_graph
end


 function run_quantum_computation(client::AbstractClient,server::AbstractServer,mg::MetaGraphs.MetaGraph{Int64, Float64})

        # Extract graph and qureg from client
        client_graph = produce_initialised_graph(Client(),client_meta_graph)
        client_qureg = produce_initialised_qureg(Client(),client_meta_graph)
        
        # Create server resources
        server_resource = create_resource(Server(),client_graph,client_qureg)
        server_quantum_state = server_resource["quantum_state"]
        num_qubits_from_server = server_quantum_state.numQubitsRepresented
        run_computation(Client(),Server(),client_meta_graph,num_qubits_from_server,server_quantum_state)
       
        initialise_blank_quantum_state!(server_quantum_state)

        mg
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



        function initialise_blank_quantum_state!(quantum_state::Qureg)
            initBlankState(quantum_state)
        end