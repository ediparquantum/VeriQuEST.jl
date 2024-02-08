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




function init_plus_phase_state!(::NoPhase,qureg,qᵢ)
    hadamard(qureg,qᵢ)
end


function initialise_qubit(::DummyQubit,::NoInputQubits,quantum_state,qubit_index,qubit_input_value::Int)
    #qubit_index = c_shift_index(qubit_index)
    iszero(qubit_input_value) ? nothing : 
    isone(qubit_input_value) ?  pauliX(quantum_state, qubit_index) :
    throw_error(DummyQubitZeroOneInitialisationError())
end


function initialise_qubit(::Union{ComputationQubit,TrapQubit},::Union{InputQubits,InputQubits,NoInputQubits},quantum_state,qubit_index,qubit_input_value::Float64)
    qubit_input_value isa Float64 ? init_plus_phase_state!(Phase(),quantum_state,qubit_index,qubit_input_value) :
    throw_error(QubitFloatPhaseInitialisationError())
end


function initialise_qubit(::MBQC,::Union{ComputationQubit,TrapQubit},::Union{InputQubits,InputQubits,NoInputQubits},quantum_state,qubit_index)
    init_plus_phase_state!(NoPhase(),quantum_state,qubit_index)
end