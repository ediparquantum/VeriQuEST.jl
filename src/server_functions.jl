




create_quantum_env(::Server) = createQuESTEnv()
create_quantum_state(::Server,::StateVector,quantum_env,num_qubits) = createQureg(num_qubits, quantum_env)
create_quantum_state(::Server,::DensityMatrix,quantum_env,num_qubits) = createDensityQureg(num_qubits, quantum_env)

function clone_qureq(::Server,client_qureg,env)
    createCloneQureg(client_qureg, env)
end

function clone_graph(::Server,client_graph)
    client_graph
end

function entangle_graph!(::Server,qureg,graph)
    edge_iter = edges(graph)
    for e in edge_iter
        src,dst = e.src,e.dst
        controlledPhaseFlip(qureg,src,dst)
    end
end

function measure_along_ϕ_basis!(::Union{Server,NoisyServer},ψ,v::Union{Int32,Int64},ϕ::Union{Float64,Float64})
    #v = c_shift_index(v)
    rotateZ(ψ,v,-ϕ)
    hadamard(ψ,v)
    measure(ψ,v)
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