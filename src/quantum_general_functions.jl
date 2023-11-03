##################################################################
# Filename  : quantum_functions.jl
# Author    : Jonathan Miller
# Date      : 2023-07-07
# Aim       : aim_script
#           : Functions that are used with QuEST
#           : but are written in Julia alone.
##################################################################




phase(θ) = Complex.([1 0; 0 exp(im*θ)])
ident_2x2() = Matrix{Complex{Float64}}(I, 2, 2)


get_state_vector_pair_per_qubit(x) = (2*x - 1, 2*x)

function get_density_matrix_indices_per_qubits(qubit1,qubit2)
    q₁ = get_state_vector_pair_per_qubit(qubit1)
    q₂ = get_state_vector_pair_per_qubit(qubit2)
    Iterators.product(q₁,q₂) |> collect
    
end





function create_plus_phase_density_mat(θ)
    H = (1/√(2)).*[1 1;1 -1] 
    zero_state = [1 0; 0 0]
    U = phase(θ)*H
    U*zero_state*U'
end


function get_all_amps(::DensityMatrix,quantum_state)
    num_qubits = quantum_state.numQubitsRepresented
    amps=[]
    for q₁ in Base.OneTo(num_qubits),q₂ in Base.OneTo(num_qubits)
        idx = get_density_matrix_indices_per_qubits(q₁,q₂)
        idxs = [c_shift_index.(x) for x in idx]
        qubit_amps = [QuEST.getDensityAmp(quantum_state, q[1],q[2]) for q in idxs]
        push!(amps,qubit_amps)
    end
    amps
end


# Function to add to QuESTMbqcBqpVerification 
function initialise_blank_quantum_state!(quantum_state)
    QuEST.initBlankState(quantum_state)
end