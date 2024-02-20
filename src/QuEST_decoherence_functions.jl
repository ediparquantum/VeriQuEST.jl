"""
    Quest

A type to represent the QuEST library
"""
struct Quest end

"""
    SingleQubit

A type to represent a single qubit
"""
struct SingleQubit end

"""
    TwoQubits

A type to represent two qubits
"""
struct TwoQubits end

"""
    MultipleQubits

A type to represent multiple qubits
"""
struct MultipleQubits end 

"""
    DensityMatrices

A type to represent density matrices
"""
struct DensityMatrices end

"""
    TracePreserving

A type to represent a trace preserving map
"""
struct TracePreserving end

"""
    NotTracePreserving

A type to represent a non trace preserving
"""
struct NotTracePreserving end 

"""
    ProbabilityExceedsOneError

A type to represent an error when a probability exceeds 1
"""
struct ProbabilityExceedsOneError end

"""
    ProbabilityExceedsOneHalfError

A type to represent an error when a probability exceeds 1/2
"""
struct ProbabilityExceedsOneHalfError end

"""
    ProbabilityExceedsThreeQuartersError

A type to represent an error when a probability exceeds 3/4
"""
struct ProbabilityExceedsThreeQuartersError end

"""
    ProbabilityExceedsFifteenSixteensError

A type to represent an error when a probability exceeds 15/16
"""
struct ProbabilityExceedsFifteenSixteensError end

"""
    ProbabilityLessThanZeroError

A type to represent an error when a probability is less than 0
"""
struct ProbabilityLessThanZeroError end

"""
    ProbabilityExceedsNoErrorExceeded

A type to represent an error when a probability exceeds no error
"""
struct ProbabilityExceedsNoErrorExceeded end

"""
    DimensionMismatchDensityMatrices

A type to represent an error when density matrices do not have the same dimensions
"""
struct DimensionMismatchDensityMatrices end

"""
    ExceededNumKrausOperators

A type to represent an error when more Kraus operators were presented than allowed
"""
struct ExceededNumKrausOperators end

"""
    UntestedKrausFunction

A type to represent a warning when a Kraus operator is not tested
"""
struct UntestedKrausFunction end

"""
    OnlySingleQubitNoiseInUseError

A type to represent an error when two qubit or multiple qubit noise is not tested
"""
struct OnlySingleQubitNoiseInUseError end


"""
    throw_error(::ProbabilityLessThanZeroError)

Throws an error when a probability less than zero is encountered.

# Examples
```julia
throw_error(ProbabilityLessThanZeroError()) # Throws an error with the message "Probability is less than 0 (hint: not a probability and threw an error)"
```
"""
function throw_error(::ProbabilityLessThanZeroError)
    error("Probability is less than 0 (hint: not a probability and threw an error)")
end



"""
    throw_error(::ProbabilityExceedsOneHalfError)

Throws an error when a probability greater than 1/2 is encountered, typically in relation to noise model limitations.

# Examples
```julia
throw_error(ProbabilityExceedsOneHalfError()) # Throws an error with the message "Probability is greater than 1/2 (hint: error thrown in relation to noise model limitations)"
```
"""
function throw_error(::ProbabilityExceedsOneHalfError)
    error("Probability is greater than 1/2 (hint: error thrown in relation to noise model limitations)")
end


"""
    throw_error(::ProbabilityExceedsThreeQuartersError)

Throws an error when a probability greater than 3/4 is encountered, typically in relation to noise model limitations.

# Examples
```julia
throw_error(ProbabilityExceedsThreeQuartersError()) # Throws an error with the message "Probability is greater than 3/4 (hint: error thrown in relation to noise model limitations)"
```
"""
function throw_error(::ProbabilityExceedsThreeQuartersError)
    error("Probability is greater than 3/4 (hint: error thrown in relation to noise model limitations)")
end


"""
    throw_error(::ProbabilityExceedsFifteenSixteensError)

Throws an error when a probability greater than 15/16 is encountered, typically in relation to noise model limitations.

# Examples
```julia
throw_error(ProbabilityExceedsFifteenSixteensError()) # Throws an error with the message "Probability is greater than 15/16 (hint: error thrown in relation to noise model limitations)"
```
"""
function throw_error(::ProbabilityExceedsFifteenSixteensError)
    error("Probability is greater than 15/16 (hint: error thrown in relation to noise model limitations)")
end


"""
    throw_error(::ProbabilityExceedsOneError)

Throws an error when a probability greater than 1 is encountered.

# Examples
```julia
throw_error(ProbabilityExceedsOneError()) # Throws an error with the message "Probability is greater than 1 (hint: not a probability and threw an error)"
```
"""
function throw_error(::ProbabilityExceedsOneError)
    error("Probability is greater than 1 (hint: not a probability and threw an error)")
end


"""
    throw_error(::ProbabilityExceedsNoErrorExceeded)

Throws an error when a probability is greater than no error from 1.

# Examples
```julia
throw_error(ProbabilityExceedsNoErrorExceeded()) # Throws an error with the message "Probability is greater than no error from 1."
```
"""
function throw_error(::ProbabilityExceedsNoErrorExceeded)
    error("Probability is greater than no error from 1.")
end


"""
    throw_error(::DimensionMismatchDensityMatrices)

Throws an error when density matrices do not have the same dimensions.

# Examples
```julia
throw_error(DimensionMismatchDensityMatrices()) # Throws an error with the message "Density matrices do not have the same dimensions"
```
"""
function throw_error(::DimensionMismatchDensityMatrices)
    error("Density matrices do not have the same dimensions")
end


"""
    throw_error(::ExceededNumKrausOperators)

Throws an error when more Kraus operators were presented than allowed.

# Examples
```julia
throw_error(ExceededNumKrausOperators()) # Throws an error with the message "More Kraus operators were presented than allowed. Check again."
```
"""
function throw_error(::ExceededNumKrausOperators)
    error("More Kraus operators were presented than allowed. Check again.")
end


"""
    throw_error(::OnlySingleQubitNoiseInUseError)

Throws an error when two qubit or multiple qubit noise is not tested.

# Examples
```julia
throw_error(OnlySingleQubitNoiseInUseError()) # Throws an error with the message "Two qubit or multiple qubit noise is not tested and will not be allowed to run, untill"
```
"""
function throw_error(::OnlySingleQubitNoiseInUseError)
    error("Two qubit or multiple qubit noise is not tested and will not be allowed to run, untill")
end

"""
    throw_warning(::UntestedKrausFunction)

Throws a warning when a Kraus operator is not tested, specifically transalting a pointer index from Julia to C, use at peril till function goes away.

# Examples
```julia
throw_warning(UntestedKrausFunction()) # Throws a warning with the message "Kraus operator is not tested, specifically transalting a pointer index from Julia to C, use at peril till function goes away"
```
"""
function throw_warning(::UntestedKrausFunction)
    @warn "Kraus operator is not tested, specifically transalting a pointer index from Julia to C, use at peril till function goes away"
end



"""
    mixBitFlip(ρ::Array{Complex{Float64},2},q::Int64,p::Float64)

Mixes a bit flip noise model to a density matrix.

# Arguments
- `ρ::QuEST density matrix`: The density matrix to apply the noise to
- `q::Int64`: The qubit to apply the noise to
- `p::Float64`: The probability of the noise


"""
function add_bit_flip!(::Quest,::SingleQubit,ρ,q,p)
    p > 1.0 && throw_error(ProbabilityExceedsOneError())
    mixBitFlip(ρ,q,p)
end


"""
    mixDamping(ρ::Array{Complex{Float64},2},q::Int64,p::Float64)

Mixes a damping noise model to a density matrix.

# Arguments
- `ρ::QuEST density matrix`: The density matrix to apply the noise to
- `q::Int64`: The qubit to apply the noise to
- `p::Float64`: The probability of the noise

# Examples
```julia    
num_qubits = 1
q = 1
p = 0.3
quantum_env = createQuESTEnv()
ρ = createDensityQureg(num_qubits, quantum_env)
add_damping!(Quest(),SingleQubit(),ρ,q,p)
"""
function add_damping!(::Quest,::SingleQubit,ρ,q,p)
    p > 1.0 && throw_error(ProbabilityExceedsOneError())
    mixDamping(ρ,q,p)
end


"""
    add_dephasing!(::Quest,::SingleQubit,ρ,q,p)

Adds a dephasing noise model to a density matrix.

# Arguments
- `::Quest`: Indicates that this function is used in the context of a Quest environment.
- `::SingleQubit`: Indicates that the noise is applied to a single qubit.
- `ρ::QuEST density matrix`: The density matrix to apply the noise to.
- `q::Int64`: The qubit to apply the noise to.
- `p::Float64`: The probability of the noise.

# Examples
```julia    
num_qubits = 1
q = 1
p = 0.3
quantum_env = createQuESTEnv()
ρ = createDensityQureg(num_qubits, quantum_env)
add_dephasing!(Quest(),SingleQubit(),ρ,q,p) 
```
"""
function add_dephasing!(::Quest,::SingleQubit,ρ,q,p)
    p > 1/2 && throw_error(ProbabilityExceedsOneHalfError())
    mixDephasing(ρ,q,p)
end 



"""
    add_dephasing!(::Quest,::TwoQubits,ρ,q,p)

Adds a dephasing noise model to a density matrix for two qubits.

# Arguments
- `::Quest`: Indicates that this function is used in the context of a Quest environment.
- `::TwoQubits`: Indicates that the noise is applied to two qubits.
- `ρ::QuEST density matrix`: The density matrix to apply the noise to.
- `q::Tuple{Int64, Int64}`: The qubits to apply the noise to.
- `p::Float64`: The probability of the noise.

# Examples
```julia    
num_qubits = 2
q = (1, 2)
p = 0.3
quantum_env = createQuESTEnv()
ρ = createDensityQureg(num_qubits, quantum_env)
add_dephasing!(Quest(),TwoQubits(),ρ,q,p)
```
"""
function add_dephasing!(::Quest,::TwoQubits,ρ,q,p)
    q₁,q₂ = q
    p > 3/4 && throw_error(ProbabilityExceedsThreeQuartersError())
    mixTwoQubitDephasing(ρ,q₁,q₂,p)
end 

"""
    add_depolarising!(::Quest,::SingleQubit,ρ,q,p)

Adds a depolarising noise model to a density matrix for a single qubit.

# Arguments
- `::Quest`: Indicates that this function is used in the context of a Quest environment.
- `::SingleQubit`: Indicates that the noise is applied to a single qubit.
- `ρ::QuEST density matrix`: The density matrix to apply the noise to.
- `q::Int64`: The qubit to apply the noise to.
- `p::Float64`: The probability of the noise.

# Examples
```julia    
num_qubits = 1
q = 1
p = 0.3
quantum_env = createQuESTEnv()
ρ = createDensityQureg(num_qubits, quantum_env)
add_depolarising!(Quest(),SingleQubit(),ρ,q,p)
```
"""
function add_depolarising!(::Quest,::SingleQubit,ρ,q,p)
    p > 3/4 && throw_error(ProbabilityExceedsThreeQuartersError())
    mixDepolarising(ρ,q,p)
end 


"""
    add_depolarising!(::Quest,::TwoQubits,ρ,q,p)

Adds a depolarising noise model to a density matrix for two qubits.

# Arguments
- `::Quest`: Indicates that this function is used in the context of a Quest environment.
- `::TwoQubits`: Indicates that the noise is applied to two qubits.
- `ρ::QuEST density matrix`: The density matrix to apply the noise to.
- `q::Tuple{Int64, Int64}`: The qubits to apply the noise to.
- `p::Float64`: The probability of the noise.

# Examples
```julia    
num_qubits = 2
q = (1, 2)
p = 0.3
quantum_env = createQuESTEnv()
ρ = createDensityQureg(num_qubits, quantum_env)
add_depolarising!(Quest(),TwoQubits(),ρ,q,p)
```
"""
function add_depolarising!(::Quest,::TwoQubits,ρ,q,p)
    q₁,q₂ = q
    p > 15/16 && throw_error(ProbabilityExceedsFifteenSixteensError())
    mixTwoQubitDepolarising(ρ,q₁,q₂,p)
end 


"""
    add_pauli_noise!(::Quest,::SingleQubit,ρ,q,p)

Adds a Pauli noise model to a density matrix for a single qubit.

# Arguments
- `::Quest`: Indicates that this function is used in the context of a Quest environment.
- `::SingleQubit`: Indicates that the noise is applied to a single qubit.
- `ρ::QuEST density matrix`: The density matrix to apply the noise to.
- `q::Int64`: The qubit to apply the noise to.
- `p::Tuple{Float64, Float64, Float64}`: The probabilities of the X, Y, and Z Pauli errors.

# Examples
```julia    
num_qubits = 1
q = 1
p = (0.1, 0.2, 0.3)
quantum_env = createQuESTEnv()
ρ = createDensityQureg(num_qubits, quantum_env)
add_pauli_noise!(Quest(),SingleQubit(),ρ,q,p)
```
"""
function add_pauli_noise!(::Quest,::SingleQubit,ρ,q,p)
    px,py,pz = p
    prob_no_error = 1 - px - py - pz
    px > prob_no_error && throw_error(ProbabilityExceedsNoErrorExceeded())
    py > prob_no_error && throw_error(ProbabilityExceedsNoErrorExceeded())
    pz > prob_no_error && throw_error(ProbabilityExceedsNoErrorExceeded())
    mixPauli(ρ,q,px,py,pz)
end
 

"""
    apply_kraus_map!(::Quest,::SingleQubit,::TracePreserving,ρ,q,complex_mat,num_ops)

Applies a Kraus map to a density matrix for a single qubit.

# Arguments
- `::Quest`: Indicates that this function is used in the context of a Quest environment.
- `::SingleQubit`: Indicates that the operation is applied to a single qubit.
- `::TracePreserving`: Indicates that the operation is trace preserving.
- `ρ::QuEST density matrix`: The density matrix to apply the operation to.
- `q::Int64`: The qubit to apply the operation to.
- `complex_mat::Array{ComplexF64, 3}`: The array of Kraus operators.
- `num_ops::Int64`: The number of Kraus operators.

# Examples
```julia    
num_qubits = 1
q = 1
num_ops = 2
complex_mat = Array{ComplexF64, 3}(undef, 2, 2, num_ops)
quantum_env = createQuESTEnv()
ρ = createDensityQureg(num_qubits, quantum_env)
apply_kraus_map!(Quest(),SingleQubit(),TracePreserving(),ρ,q,complex_mat,num_ops)
```
"""
function apply_kraus_map!(::Quest,::SingleQubit,::TracePreserving,ρ,q,complex_mat,num_ops)
    throw_warning(UntestedKrausFunction())
    num_ops > 4 && throw_error(ExceededNumKrausOperators())
    mixKrausMap(ρ,q,complex_mat,num_ops)
end


"""
    apply_kraus_map!(::Quest,::TwoQubits,::TracePreserving,ρ,q,complex_mat,num_ops)

Applies a Kraus map to a density matrix for two qubits.

# Arguments
- `::Quest`: Indicates that this function is used in the context of a Quest environment.
- `::TwoQubits`: Indicates that the operation is applied to two qubits.
- `::TracePreserving`: Indicates that the operation is trace preserving.
- `ρ::QuEST density matrix`: The density matrix to apply the operation to.
- `q::Tuple{Int64, Int64}`: The qubits to apply the operation to.
- `complex_mat::Array{ComplexF64, 4}`: The array of Kraus operators.
- `num_ops::Int64`: The number of Kraus operators.

# Examples
```julia    
num_qubits = 2
q = (1, 2)
num_ops = 4
complex_mat = Array{ComplexF64, 4}(undef, 2, 2, 2, num_ops)
quantum_env = createQuESTEnv()
ρ = createDensityQureg(num_qubits, quantum_env)
apply_kraus_map!(Quest(),TwoQubits(),TracePreserving(),ρ,q,complex_mat,num_ops)
```
"""
function apply_kraus_map!(::Quest,::TwoQubits,::TracePreserving,ρ,q,complex_mat,num_ops)
    throw_warning(UntestedKrausFunction())
    q₁,q₂ = q
    num_ops > 16 && throw_error(ExceededNumKrausOperators())
    mixTwoQubitKrausMap(ρ,q,complex_mat,num_ops)
end


"""
    apply_kraus_map!(::Quest,::MultipleQubits,::TracePreserving,ρ,leas_sig_qubit,num_qubits,complex_mat,num_ops)

Applies a Kraus map to a density matrix for multiple qubits.

# Arguments
- `::Quest`: Indicates that this function is used in the context of a Quest environment.
- `::MultipleQubits`: Indicates that the operation is applied to multiple qubits.
- `::TracePreserving`: Indicates that the operation is trace preserving.
- `ρ::QuEST density matrix`: The density matrix to apply the operation to.
- `leas_sig_qubit::Int64`: The least significant qubit.
- `num_qubits::Int64`: The number of qubits.
- `complex_mat::Array{ComplexF64, 3}`: The array of Kraus operators.
- `num_ops::Int64`: The number of Kraus operators.

# Examples
```julia    
num_qubits = 3
leas_sig_qubit = 1
num_ops = 8
complex_mat = Array{ComplexF64, 3}(undef, 2, 2, num_ops)
quantum_env = createQuESTEnv()
ρ = createDensityQureg(num_qubits, quantum_env)
apply_kraus_map!(Quest(),MultipleQubits(),TracePreserving(),ρ,leas_sig_qubit,num_qubits,complex_mat,num_ops)
```
"""
function apply_kraus_map!(::Quest,::MultipleQubits,::TracePreserving,ρ,leas_sig_qubit,num_qubits,complex_mat,num_ops)
    throw_warning(UntestedKrausFunction())
    num_ops > (2*num_qubits)^2 && throw_error(ExceededNumKrausOperators())
    leas_sig_qubit = q₁
    mixMultiQubitKrausMap(ρ,leas_sig_qubit,num_qubits,complex_mat,num_ops)
end



"""
    apply_kraus_map!(::Quest,::SingleQubit,::NotTracePreserving,ρ,q,complex_mat,num_ops)

Applies a non-trace preserving Kraus map to a density matrix for a single qubit.

# Arguments
- `::Quest`: Indicates that this function is used in the context of a Quest environment.
- `::SingleQubit`: Indicates that the operation is applied to a single qubit.
- `::NotTracePreserving`: Indicates that the operation is not trace preserving.
- `ρ::QuEST density matrix`: The density matrix to apply the operation to.
- `q::Int64`: The qubit to apply the operation to.
- `complex_mat::Array{ComplexF64, 3}`: The array of Kraus operators.
- `num_ops::Int64`: The number of Kraus operators.

# Examples
```julia    
num_qubits = 1
q = 1
num_ops = 2
complex_mat = Array{ComplexF64, 3}(undef, 2, 2, num_ops)
quantum_env = createQuESTEnv()
ρ = createDensityQureg(num_qubits, quantum_env)
apply_kraus_map!(Quest(),SingleQubit(),NotTracePreserving(),ρ,q,complex_mat,num_ops)
```
"""
function apply_kraus_map!(::Quest,::SingleQubit,::NotTracePreserving,ρ,q,complex_mat,num_ops)
    throw_warning(UntestedKrausFunction())
    num_ops > 4 && throw_error(ExceededNumKrausOperators())
    mixNonTPKrausMap(ρ,q,complex_mat,num_ops)
end


"""
    apply_kraus_map!(::Quest,::TwoQubits,::NotTracePreserving,ρ,q,complex_mat,num_ops)

Applies a non-trace preserving Kraus map to a density matrix for two qubits.

# Arguments
- `::Quest`: Indicates that this function is used in the context of a Quest environment.
- `::TwoQubits`: Indicates that the operation is applied to two qubits.
- `::NotTracePreserving`: Indicates that the operation is not trace preserving.
- `ρ::QuEST density matrix`: The density matrix to apply the operation to.
- `q::Tuple{Int64, Int64}`: The qubits to apply the operation to.
- `complex_mat::Array{ComplexF64, 4}`: The array of Kraus operators.
- `num_ops::Int64`: The number of Kraus operators.

# Examples
```julia    
num_qubits = 2
q = (1, 2)
num_ops = 4
complex_mat = Array{ComplexF64, 4}(undef, 2, 2, 2, num_ops)
quantum_env = createQuESTEnv()
ρ = createDensityQureg(num_qubits, quantum_env)
apply_kraus_map!(Quest(),TwoQubits(),NotTracePreserving(),ρ,q,complex_mat,num_ops)
```
"""
function apply_kraus_map!(::Quest,::TwoQubits,::NotTracePreserving,ρ,q,complex_mat,num_ops)
    throw_warning(UntestedKrausFunction())
    q₁,q₂ = q
    num_ops > 16 && throw_error(ExceededNumKrausOperators())
    mixNonTPTwoQubitKrausMap(ρ,q,complex_mat,num_ops)
end



"""
    apply_kraus_map!(::Quest,::MultipleQubits,::NotTracePreserving,ρ,q,complex_mat,num_ops)

Applies a non-trace preserving Kraus map to a density matrix for multiple qubits.

# Arguments
- `::Quest`: Indicates that this function is used in the context of a Quest environment.
- `::MultipleQubits`: Indicates that the operation is applied to multiple qubits.
- `::NotTracePreserving`: Indicates that the operation is not trace preserving.
- `ρ::QuEST density matrix`: The density matrix to apply the operation to.
- `q::Tuple{Int64, Int64}`: The least significant qubit and the number of qubits.
- `complex_mat::Array{ComplexF64, 3}`: The array of Kraus operators.
- `num_ops::Int64`: The number of Kraus operators.

# Examples
```julia    
num_qubits = 3
leas_sig_qubit = 1
num_ops = 8
complex_mat = Array{ComplexF64, 3}(undef, 2, 2, num_ops)
quantum_env = createQuESTEnv()
ρ = createDensityQureg(num_qubits, quantum_env)
apply_kraus_map!(Quest(),MultipleQubits(),NotTracePreserving(),ρ,(leas_sig_qubit,num_qubits),complex_mat,num_ops)
```
"""
function apply_kraus_map!(::Quest,::MultipleQubits,::NotTracePreserving,ρ,q,complex_mat,num_ops)
    throw_warning(UntestedKrausFunction())
    leas_sig_qubit,num_qubits = q
    num_ops > (2*num_qubits)^2 && throw_error(ExceededNumKrausOperators())
    leas_sig_qubit = q₁
    mixNonTPMultiQubitKrausMap(ρ,leas_sig_qubit,num_qubits,complex_mat,num_ops)
end



"""
    mix_two_density_matrices!(::Quest,::DensityMatrices,ρ₁,ρ₂,p)

Mixes two density matrices with a given probability.

# Arguments
- `::Quest`: Indicates that this function is used in the context of a Quest environment.
- `::DensityMatrices`: Indicates that the operation is applied to density matrices.
- `ρ₁::QuEST density matrix`: The first density matrix.
- `ρ₂::QuEST density matrix`: The second density matrix.
- `p::Float64`: The probability of mixing.

# Examples
```julia    
num_qubits = 2
quantum_env = createQuESTEnv()
ρ₁ = createDensityQureg(num_qubits, quantum_env)
ρ₂ = createDensityQureg(num_qubits, quantum_env)
p = 0.5
mix_two_density_matrices!(Quest(),DensityMatrices(),ρ₁,ρ₂,p)
```
"""
function mix_two_density_matrices!(::Quest,::DensityMatrices,ρ₁,ρ₂,p)
    p > 1.0 && throw_error(ProbabilityExceedsOneError())
    p < 0.0 && throw_error(ProbabilityLessThanZeroError())
    ρ₁.numQubitsRepresented == ρ₂.numQubitsRepresented && 
        throw_error(DimensionMismatchDensityMatrices())
    mixDensityMatrix(ρ₁,p,ρ₂)
end 