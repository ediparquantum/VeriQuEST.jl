
###### Initialise qubits

"""
init_plus_phase_state!(qureg,qᵢ,φᵢ)

    Applies a Hadamard gate (|+⟩) then a phase rotation gate (|+_ϕ⟩)
    - ψ: State vector or density matrix
    - qᵢ: Qubit to be applied gates to, index must be 1 based as c_shift_index is called.
    - φᵢ: Angle for phase shift
"""
function init_plus_phase_state!(::Phase,qureg,qᵢ,φᵢ)
    qᵢ = c_shift_index(qᵢ)
    QuEST.hadamard(qureg,qᵢ)
    QuEST.rotateZ(qureg,qᵢ,φᵢ)
    #QuEST.phaseShift(qureg,qᵢ,φᵢ)
end



"""
    plusState(qureg, qᵢ)

    Applies a Hadamard gate (|+⟩) to the specified qubit.

    # Arguments
    - `qureg`: State vector or density matrix.
    - `qᵢ`: Qubit index to which the Hadamard gate is applied. Index must be 1-based, as `c_shift_index` is called.
"""
function init_plus_phase_state!(::NoPhase,qureg,qᵢ)
    qᵢ = c_shift_index(qᵢ)
    QuEST.hadamard(qureg,qᵢ)
end


function initialise_qubit(::DummyQubit,::NoInputQubits,quantum_state,qubit_index,qubit_input_value::Int)
    qubit_index = c_shift_index(qubit_index)
    iszero(qubit_input_value) ? nothing : 
    isone(qubit_input_value) ?  QuEST.pauliX(quantum_state, qubit_index) :
    throw_error(DummyQubitZeroOneInitialisationError())
end


function initialise_qubit(::Union{ComputationQubit,TrapQubit},::Union{InputQubits,InputQubits,NoInputQubits},quantum_state,qubit_index,qubit_input_value::Float64)
    qubit_input_value isa Float64 ? init_plus_phase_state!(Phase(),quantum_state,qubit_index,qubit_input_value) :
    throw_error(QubitFloatPhaseInitialisationError())
end


function initialise_qubit(::MBQC,::Union{ComputationQubit,TrapQubit},::Union{InputQubits,InputQubits,NoInputQubits},quantum_state,qubit_index)
    init_plus_phase_state!(NoPhase(),quantum_state,qubit_index)
end