




create_quantum_env(::Server) = QuEST.createQuESTEnv()
create_quantum_state(::Server,::StateVector,quantum_env,num_qubits) = QuEST.createQureg(num_qubits, quantum_env)
create_quantum_state(::Server,::DensityMatrix,quantum_env,num_qubits) = QuEST.createDensityQureg(num_qubits, quantum_env)

function clone_qureq(::Server,client_qureg,env)
    QuEST.createCloneQureg(client_qureg, env)
end

function clone_graph(::Server,client_graph)
    client_graph
end

function entangleGraph!(::Server,qureg,graph)
    edge_iter = edges(graph)
    for e in edge_iter
        src,dst = c_shift_index(e.src),c_shift_index(e.dst)
        QuEST.controlledPhaseFlip(qureg,src,dst)
    end
end

function measure_along_ϕ_basis!(::Server,ψ,v::Union{Int32,Int64},ϕ::qreal)
    v = c_shift_index(v)
    QuEST.rotateZ(ψ,v,-ϕ)
    QuEST.hadamard(ψ,v)
    QuEST.measure(ψ,v)
end



function create_resource(::Server,client_graph,client_qureg)
    # Server copies/clones data and structures
    server_graph = clone_graph(Server(),client_graph)
    server_env = create_quantum_env(Server())
    server_qureg = clone_qureq(Server(),client_qureg,server_env)

    #  Server entangles graph
    entangleGraph!(Server(),server_qureg,server_graph)
    return Dict("env"=>server_env,"quantum_state"=>server_qureg,"graph"=>server_graph)
end