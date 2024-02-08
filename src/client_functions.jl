
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




"""
    update_measurement(client::Client, round::ComputationRound, q, mg, outcome)

Update the measurement for a given computation round and qubit. The function retrieves the one-time pad integer 
associated with the qubit and computes the absolute difference between the outcome and the one-time pad integer.

# Arguments
- `client::Client`: The client for which the measurement is being updated.
- `round::ComputationRound`: The computation round for which the measurement is being updated.
- `q`: The qubit for which the measurement is being updated.
- `mg`: The measurement graph associated with the computation round.
- `outcome`: The outcome of the measurement.

# Returns
- The absolute difference between the outcome and the one-time pad integer.

# Examples
```julia
client = Client()
round = ComputationRound()
q = 1
mg = MeasurementGraph()
outcome = 0
update_measurement(client, round, q, mg, outcome)
```
"""
function update_measurement(::Client,::ComputationRound,q,mg,outcome)
    one_time_pad_int = get_prop(mg,q,:one_time_pad_int)
    abs(outcome-one_time_pad_int)	
end

"""
    update_measurement(client::Client, round::Union{MBQC, TestRound}, q, mg, outcome)

This function is used in the context of Measurement-Based Quantum Computing (MBQC) or during a test round. 
It takes an outcome and simply returns it without making any modifications.

# Arguments
- `client::Client`: The client for which the measurement is being updated.
- `round::Union{MBQC, TestRound}`: Specifies whether the computation round is a part of MBQC or a test round.
- `q`: The qubit for which the measurement is being updated.
- `mg`: The measurement graph associated with the computation round.
- `outcome`: The outcome of the measurement.

# Returns
- The same `outcome` that was passed as an argument.

# Examples
```julia
client = Client()
round = MBQC()
q = 1
mg = MeasurementGraph()
outcome = 0
update_measurement(client, round, q, mg, outcome)
```
"""
function update_measurement(::Client,::Union{MBQC,TestRound},q,mg,outcome)
    outcome
end


"""
    update_measurement(client::Client, q, mg, outcome)

This function retrieves the round type from the measurement graph and then calls the `update_measurement` function 
with the client, round type, qubit, measurement graph, and outcome as arguments.

# Arguments
- `client::Client`: The client for which the measurement is being updated.
- `q`: The qubit for which the measurement is being updated.
- `mg`: The measurement graph associated with the computation round.
- `outcome`: The outcome of the measurement.

# Returns
- The result of calling `update_measurement` with the client, round type, qubit, measurement graph, and outcome.

# Examples
```julia
client = Client()
q = 1
mg = MeasurementGraph()
outcome = 0
update_measurement(client, q, mg, outcome)
```
"""
function update_measurement(::Client,q,mg,outcome)
    RT = get_prop(mg,:round_type)
    update_measurement(Client(),RT,q,mg,outcome)
end

"""
        NoisyClient(noise_model::Union{Vector{NoiseModel}, NoiseModel})

For MBQC only.
A structure representing a client that operates under some noise model.
May be buggy.

# Fields
- `noise_model::Union{Vector{NoiseModel}, NoiseModel}`: The noise model under which the client operates. 
    This can be a single `NoiseModel` or a vector of `NoiseModel`s.

# Examples
```julia
noise_model = NoiseModel()
client = NoisyClient(noise_model)
```
"""
struct NoisyClient 
    noise_model::Union{Vector{NoiseModel},NoiseModel}
end

"""
    add_noise!(client::Client, model::Union{Damping,Dephasing,Depolarising,Pauli}, params::QubitNoiseParameters)

This function adds noise to a quantum system. The noise model can be one of Damping, Dephasing, Depolarising, or Pauli. 
The function throws an error if the noise type is not SingleQubit. It then iterates over the range of qubits represented 
in the backend and adds noise to each qubit according to the specified model and parameters.

# Arguments
- `client::Client`: The client for which the noise is being added.
- `model::Union{Damping,Dephasing,Depolarising,Pauli}`: The noise model to be used.
- `params::QubitNoiseParameters`: The parameters for the noise model.

# Examples
```julia
client = Client()
model = Damping()
params = QubitNoiseParameters(SingleQubit(), backend)
add_noise!(client, model, params)
```
"""
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

"""
    add_noise!(client::Client, noise_model::NoiseModel)

This function adds noise to a quantum system according to the specified noise model. It calls the `add_noise!` function 
with a new client and the given noise model as arguments.

# Arguments
- `client::Client`: The client for which the noise is being added.
- `noise_model::NoiseModel`: The noise model to be used.

# Examples
```julia
client = Client()
noise_model = NoiseModel()
add_noise!(client, noise_model)
```
"""
function add_noise!(
    ::Client,noise_model::NoiseModel)
    add_noise!(Client(),noise_model)
end

