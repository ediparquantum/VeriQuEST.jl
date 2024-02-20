##################################################################
# Filename  : server_functions.jl
# Author    : Jonathan Miller
# Date      : 2024-02-12
# Aim       : aim_script
#           : Functions for the "server" in the client-server model
#           :
##################################################################





"""
    create_quantum_env(::Server)

Creates a new QuEST environment in the context of a server.

# Arguments
- `::Server`: Indicates that this function is used in the context of a server.

# Examples
```julia    
create_quantum_env(Server())
```
"""
create_quantum_env(::Server) = createQuESTEnv()

"""
    create_quantum_state(::Server,::StateVector,quantum_env,num_qubits)

Creates a new quantum state in the context of a server.

# Arguments
- `::Server`: Indicates that this function is used in the context of a server.
- `::StateVector`: Indicates that the quantum state is a state vector.
- `quantum_env`: The QuEST environment in which the quantum state is created.
- `num_qubits`: The number of qubits in the quantum state.

# Examples
```julia
create_quantum_state(Server(),StateVector(),quantum_env,num_qubits)
```
"""
create_quantum_state(::Server,::StateVector,quantum_env,num_qubits) = createQureg(num_qubits, quantum_env)

"""
    create_quantum_state(::Server,::DensityMatrix,quantum_env,num_qubits)

Creates a new quantum state in the context of a server.

# Arguments
- `::Server`: Indicates that this function is used in the context of a server.
- `::DensityMatrix`: Indicates that the quantum state is a density matrix.
- `quantum_env`: The QuEST environment in which the quantum state is created.
- `num_qubits`: The number of qubits in the quantum state.

# Examples
```julia
create_quantum_state(Server(),DensityMatrix(),quantum_env,num_qubits)
```
"""
create_quantum_state(::Server,::DensityMatrix,quantum_env,num_qubits) = createDensityQureg(num_qubits, quantum_env)


"""
    clone_qureq(::Server,client_qureg,env)

Creates a clone of a quantum register in the context of a server.

# Arguments
- `::Server`: Indicates that this function is used in the context of a server.
- `client_qureg`: The quantum register to be cloned.
- `env`: The QuEST environment in which the quantum register is cloned.

# Examples
```julia
clone_qureq(Server(),client_qureg,env)
```
"""
function clone_qureq(::Server,client_qureg,env)
    createCloneQureg(client_qureg, env)
end


"""
    clone_graph(::Server,client_graph)

Creates a clone of a graph in the context of a server.

# Arguments
- `::Server`: Indicates that this function is used in the context of a server.
- `client_graph`: The graph to be cloned.

# Examples
```julia
clone_graph(Server(),client_graph)
```
"""
function clone_graph(::Server,client_graph)
    client_graph
end


"""
    entangle_graph!(::Server,qureg,graph)

Entangles a quantum register with a graph in the context of a server.

# Arguments
- `::Server`: Indicates that this function is used in the context of a server.
- `qureg`: The quantum register to be entangled.
- `graph`: The graph with which the quantum register is entangled.

# Examples
```julia
entangle_graph!(Server(),qureg,graph)
```
"""
function entangle_graph!(::Server,qureg,graph)
    edge_iter = edges(graph)
    for e in edge_iter
        src,dst = e.src,e.dst
        controlledPhaseFlip(qureg,src,dst)
    end
end



"""
    measure_along_ϕ_basis!(::Server,ψ,v,ϕ)

Measures a qubit in the context of a server.

# Arguments
- `::Server`: Indicates that this function is used in the context of a server.
- `ψ`: The quantum register in which the qubit is measured.
- `v`: The index of the qubit to be measured.
- `ϕ`: The angle of the measurement.

# Examples
```julia
measure_along_ϕ_basis!(Server(),ψ,v,ϕ)
```
"""
function measure_along_ϕ_basis!(::Union{Server,NoisyServer},ψ,v::Union{Int32,Int64},ϕ::Union{Float64,Float64})
    rotateZ(ψ,v,-ϕ)
    hadamard(ψ,v)
    measure(ψ,v)
end


"""
    create_resource(::Server,client_graph,client_qureg)

Creates a resource in the context of a server.

# Arguments
- `::Server`: Indicates that this function is used in the context of a server.
- `client_graph`: The graph to be copied/cloned.
- `client_qureg`: The quantum register to be copied/cloned.

# Examples
```julia
create_resource(Server(),client_graph,client_qureg)
```
"""
function create_resource(::Server,client_graph,client_qureg)
    # Server copies/clones data and structures
    server_graph = clone_graph(Server(),client_graph)
    server_env = create_quantum_env(Server())
    server_qureg = clone_qureq(Server(),client_qureg,server_env)

    #  Server entangles graph
    entangle_graph!(Server(),server_qureg,server_graph)
    return Dict("env"=>server_env,"quantum_state"=>server_qureg,"graph"=>server_graph)
end