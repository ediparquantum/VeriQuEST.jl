##################################################################
# Filename  : quantum_functions.jl
# Author    : Jonathan Miller
# Date      : 2023-07-07
# Aim       : aim_script
#           : Functions that are used with QuEST
#           : but are written in Julia alone.
##################################################################




"""
    phase(θ)

Constructs a phase gate with the given angle θ.

# Arguments
- `θ`: The angle of the phase gate.

# Returns
A 2x2 complex matrix representing the phase gate.

# Examples
```julia
phase(π/2)
```
"""
phase(θ) = Complex.([1 0; 0 exp(im*θ)])


"""
    ident_2x2()

Constructs a 2x2 identity matrix of complex numbers.

# Returns
- `Matrix{Complex{Float64}}`: The 2x2 identity matrix.

"""
ident_2x2() = Matrix{Complex{Float64}}(I, 2, 2)






"""
    create_plus_phase_density_mat(θ)

Create a density matrix for the plus phase state with a given phase angle θ.

# Arguments
- `θ`: Phase angle in radians.

# Returns
- Density matrix representing the plus phase state with the given phase angle.

"""
function create_plus_phase_density_mat(θ)
    H = (1/√(2)).*[1 1;1 -1] 
    zero_state = [1 0; 0 0]
    U = phase(θ)*H
    U*zero_state*U'
end





"""
    initialise_blank_quantum_state!(quantum_state)
Initialise a blank quantum state.

Parameters:
- `quantum_state`: The quantum state to be initialised.

"""
function initialise_blank_quantum_state!(quantum_state)

    initBlankState(quantum_state)
end