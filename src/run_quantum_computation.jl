##################################################################
# Filename  : run_quantum_computation.jl
# Author    : Jonathan Miller
# Date      : 2024-03-13
# Aim       : aim_script
#           : Run quantum computation scripts
#           :
##################################################################




# set up quantum state
  # set up network emulation
  # run computation which is dependent on the network emulation




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