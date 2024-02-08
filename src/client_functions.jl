
"""
create_quantum_env(client::Client)

Create a new quantum environment using the QuEST environment creation function.

# Arguments
- `client::Client`: The client for which the quantum environment is being created.

# Returns
- A new quantum environment.

# Examples
```julia
client = Client()
env = create_quantum_env(client)
```
"""
create_quantum_env(::Client) = createQuESTEnv()


"""
create_quantum_state(client::Client, state::StateVector, quantum_env, num_qubits)

Create a new quantum state as a state vector using the QuEST function `createQureg`.

# Arguments
- `client::Client`: The client for which the quantum state is being created.
- `state::StateVector`: Indicates that the quantum state should be created as a state vector.
- `quantum_env`: The quantum environment in which the quantum state is being created.
- `num_qubits`: The number of qubits in the quantum state.

# Returns
- A new quantum state as a state vector.

# Examples
```julia
client = Client()
env = create_quantum_env(client)
state = create_quantum_state(client, StateVector(), env, 2)
```
"""
create_quantum_state(::Client,::StateVector,quantum_env,num_qubits) = createQureg(num_qubits, quantum_env)



"""
    create_quantum_state(client::Client, density_matrix::DensityMatrix, quantum_env, num_qubits)

Create a quantum state using a density matrix representation.

# Arguments
- `client::Client`: The client object representing the quantum computing service.
- `density_matrix::DensityMatrix`: The density matrix object representing the quantum state.
- `quantum_env`: The quantum environment object.
- `num_qubits`: The number of qubits to be used in the quantum state.

# Returns
- The quantum state represented as a density matrix.

# Examples
```julia
client = Client()
env = create_quantum_env(client)
state = create_quantum_state(client, DensityMatrix(), env, 2)
```
"""
create_quantum_state(::Client,::DensityMatrix,quantum_env,num_qubits) = createDensityQureg(num_qubits, quantum_env)





function update_measurement(::Client,::ComputationRound,q,mg,outcome)
    one_time_pad_int = get_prop(mg,q,:one_time_pad_int)
    abs(outcome-one_time_pad_int)	
end

function update_measurement(::Client,::Union{MBQC,TestRound},q,mg,outcome)
    outcome
end

function update_measurement(::Client,q,mg,outcome)
    RT = get_prop(mg,:round_type)
    update_measurement(Client(),RT,q,mg,outcome)
end

struct NoisyClient 
    noise_model::Union{Vector{NoiseModel},NoiseModel}
end

function add_noise!(
    ::Client,
    model::Union{Damping,Dephasing,Depolarising,Pauli},
    params::QubitNoiseParameters)
    !(params.type isa SingleQubit) && throw_error(OnlySingleQubitNoiseInUseError())
    qubit_range = Base.OneTo(params.backend.numQubitsRepresented)
    for q in qubit_range
        params.q = q
        add_noise!(model,params)
    end
end

function add_noise!(
    ::Client,noise_model::NoiseModel)
    add_noise!(noise_model)
end

