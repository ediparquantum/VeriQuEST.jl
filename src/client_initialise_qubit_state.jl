"""
    init_plus_phase_state!(phase::Phase, qureg, qᵢ, φᵢ)

This function initializes a quantum state to a superposition state (|+⟩ state) with a specified phase. 
It first applies a Hadamard gate to the qubit, putting it into a superposition state. 
Then it applies a Z rotation to the qubit, adding the specified phase.

# Arguments
- `phase::Phase`: The phase object.
- `qureg`: The quantum register containing the qubit.
- `qᵢ`: The index of the qubit in the quantum register.
- `φᵢ`: The phase to be added to the qubit.

# Examples
```julia
phase = Phase()
qureg = createQureg(1, env)
qᵢ = 1
φᵢ = π/2
init_plus_phase_state!(phase, qureg, qᵢ, φᵢ)
```
"""
function init_plus_phase_state!(::Phase,qureg,qᵢ,φᵢ)
    hadamard(qureg,qᵢ)
    rotateZ(qureg,qᵢ,φᵢ)
end


"""
    init_plus_phase_state!(nophase::NoPhase, qureg, qᵢ)

This function initializes a quantum state to a superposition state (|+⟩ state) without adding any phase. 
It applies a Hadamard gate to the qubit, putting it into a superposition state.

# Arguments
- `nophase::NoPhase`: The NoPhase object indicating that no phase is to be added.
- `qureg`: The quantum register containing the qubit.
- `qᵢ`: The index of the qubit in the quantum register.

# Examples
```julia
nophase = NoPhase()
qureg = createQureg(1, env)
qᵢ = 1
init_plus_phase_state!(nophase, qureg, qᵢ)
```
"""
function init_plus_phase_state!(::NoPhase,qureg,qᵢ)
    hadamard(qureg,qᵢ)
end


"""
    initialise_qubit(dummy::DummyQubit, noinput::NoInputQubits, quantum_state, qubit_index, qubit_input_value::Int)

This function initialises a qubit in a quantum state. If the input value for the qubit is zero, it does nothing. 
If the input value is one, it applies a Pauli-X gate to the qubit. If the input value is neither zero nor one, 
it throws a `DummyQubitZeroOneInitialisationError`.

# Arguments
- `dummy::DummyQubit`: The DummyQubit object.
- `noinput::NoInputQubits`: The NoInputQubits object.
- `quantum_state`: The quantum state containing the qubit.
- `qubit_index`: The index of the qubit in the quantum state.
- `qubit_input_value::Int`: The input value for the qubit.

# Examples
```julia
dummy = DummyQubit()
noinput = NoInputQubits()
quantum_state = createQureg(1, env)
qubit_index = 1
qubit_input_value = 0
initialise_qubit(dummy, noinput, quantum_state, qubit_index, qubit_input_value)
```
"""
function initialise_qubit(::DummyQubit,::NoInputQubits,quantum_state,qubit_index,qubit_input_value::Int)
    iszero(qubit_input_value) ? nothing : 
    isone(qubit_input_value) ?  pauliX(quantum_state, qubit_index) :
    throw_error(DummyQubitZeroOneInitialisationError())
end


"""
    initialise_qubit(qubit::Union{ComputationQubit,TrapQubit}, input::Union{InputQubits,InputQubits,NoInputQubits}, quantum_state, qubit_index, qubit_input_value::Float64)

This function initialises a qubit in a quantum state with a phase determined by the input value. 
If the input value is a float, it initialises the qubit to a superposition state with the input value as the phase. 
If the input value is not a float, it throws a `QubitFloatPhaseInitialisationError`.

# Arguments
- `qubit::Union{ComputationQubit,TrapQubit}`: The type of the qubit.
- `input::Union{InputQubits,InputQubits,NoInputQubits}`: The input object.
- `quantum_state`: The quantum state containing the qubit.
- `qubit_index`: The index of the qubit in the quantum state.
- `qubit_input_value::Float64`: The input value for the qubit, which determines the phase.

# Examples
```julia
qubit = ComputationQubit()
input = InputQubits()
quantum_state = createQureg(1, env)
qubit_index = 1
qubit_input_value = 0.5
initialise_qubit(qubit, input, quantum_state, qubit_index, qubit_input_value)
```
"""
function initialise_qubit(::Union{ComputationQubit,TrapQubit},::Union{InputQubits,InputQubits,NoInputQubits},quantum_state,qubit_index,qubit_input_value::Float64)
    qubit_input_value isa Float64 ? init_plus_phase_state!(Phase(),quantum_state,qubit_index,qubit_input_value) :
    throw_error(QubitFloatPhaseInitialisationError())
end


"""
    initialise_qubit(mbqc::MBQC, qubit::Union{ComputationQubit,TrapQubit}, input::Union{InputQubits,InputQubits,NoInputQubits}, quantum_state, qubit_index)

This function initialises a qubit in a quantum state to a superposition state without adding any phase. 
It applies a Hadamard gate to the qubit, putting it into a superposition state.

# Arguments
- `mbqc::MBQC`: The MBQC object.
- `qubit::Union{ComputationQubit,TrapQubit}`: The type of the qubit.
- `input::Union{InputQubits,InputQubits,NoInputQubits}`: The input object.
- `quantum_state`: The quantum state containing the qubit.
- `qubit_index`: The index of the qubit in the quantum state.

# Examples
```julia
mbqc = MBQC()
qubit = ComputationQubit()
input = InputQubits()
quantum_state = createQureg(1, env)
qubit_index = 1
initialise_qubit(mbqc, qubit, input, quantum_state, qubit_index)
```
"""
function initialise_qubit(::MBQC,::Union{ComputationQubit,TrapQubit},::Union{InputQubits,InputQubits,NoInputQubits},quantum_state,qubit_index)
    init_plus_phase_state!(NoPhase(),quantum_state,qubit_index)
end