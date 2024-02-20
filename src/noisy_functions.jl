##################################################################
# Filename  : noisy_functions.jl
# Author    : Jonathan Miller
# Date      : 2024-02-12
# Aim       : aim_script
#           : Functions that are used with QuEST
#           : but are written in Julia alone.
#           : Noise models are developed here
##################################################################



"""
    NoiseModels

An abstract type representing different noise models. Specific noise models should subtype this.


"""
abstract type NoiseModels end

"""
    NoiseParameters

An abstract type representing the parameters for noise.
"""
abstract type NoiseParameters <: NoiseModels end

"""
    NoNoiseParameters

An abstract type representing the parameters for no noise.
"""
struct NoNoiseParameters <: NoiseParameters end

"""
    mutable struct NoiseModel <: NoiseModels

A mutable struct representing a noise model.

# Fields
- `model`: The noise model.
- `params`: The parameters of the noise model.

"""
mutable struct NoiseModel <: NoiseModels 
    model
    params::NoiseParameters
end

"""
    mutable struct NoiseModelParams <: NoiseParameters

Noise model parameters for representing noise in a system.

# Fields
- `prob::Union{Float64,Float64,Vector{Float64},Vector{Float64}}`: The probability of noise occurring.

"""
mutable struct NoiseModelParams <: NoiseParameters
    prob::Union{Float64,Float64,Vector{Float64},Vector{Float64}}
end



"""
    mutable struct QubitNoiseParameters <: NoiseParameters

Qubit noise parameters for a quantum system.

# Fields
- `ρ::Union{DensityMatrix,Qureg}`: The density matrix or quantum register representing the state of the qubits.
- `q::Union{Nothing,Vector{Int64},Int64,Vector{Int32},Int32}`: The indices of the qubits affected by the noise.

"""
mutable struct QubitNoiseParameters <: NoiseParameters
    ρ::Union{DensityMatrix,Qureg}
    q::Union{Nothing,Vector{Int64},Int64,Vector{Int32},Int32}
end

"""
    mutable struct DensityMatrixMixtureParameters <: NoiseParameters

The `DensityMatrixMixtureParameters` struct represents the parameters for a density matrix mixture noise model.
It is a mutable struct that holds two density matrices, ρ₁ and ρ₂.

# Fields
- `ρ₁::Union{DensityMatrix,Qureg}`: The first density matrix.
- `ρ₂::Union{DensityMatrix,Qureg}`: The second density matrix.

"""
mutable struct DensityMatrixMixtureParameters <: NoiseParameters
    ρ₁::Union{DensityMatrix,Qureg}
    ρ₂::Union{DensityMatrix,Qureg}
end

"""
    struct KrausMapNoiseParameters <: NoiseParameters

The `KrausMapNoiseParameters` struct represents the noise parameters for a Kraus map noise model.

Fields:
- `trace`: Union{TracePreserving,NotTracePreserving} - Specifies whether the noise is trace preserving or not.
- `ρ`: Union{DensityMatrix,Qureg} - The density matrix or quantum register representing the initial state.
- `q`: Union{Nothing,Vector{Int64},Int64,Vector{Int32},Int32} - The indices of the qubits affected by the noise.
- `mat`: Matrix{ComplexF64} - The matrix representation of the Kraus operators.
- `num_ops`: Union{Int32,Int64} - The number of Kraus operators.
- `num_qubits`: Union{Nothing,Int64} - The number of qubits in the system.

"""
mutable struct KrausMapNoiseParameters <: NoiseParameters
    trace::Union{TracePreserving,NotTracePreserving}
    ρ::Union{DensityMatrix,Qureg}
    q::Union{Nothing,Vector{Int64},Int64,Vector{Int32},Int32}
    mat::Matrix{ComplexF64}
    num_ops::Union{Int32,Int64}
    num_qubits::Union{Nothing,Int64}
end

"""
    struct NoNoise <: NoiseModels

A struct representing a noise model with no noise.

# Fields
- `backend`: The backend used for the noise model.

"""
struct NoNoise <: NoiseModels 
    backend
end

"""
    struct Kraus <: NoiseModels

A struct representing a noise model using Kraus operators.

# Fields
- `backend`: The backend used for the noise model.
- `type`: The type of noise model, which can be `SingleQubit`, `TwoQubits`, or `MultipleQubits`.

"""
struct Kraus <: NoiseModels 
    backend
    type::Union{SingleQubit,TwoQubits,MultipleQubits}
end

"""
    mutable struct Damping <: NoiseModels

A struct representing a damping noise model for a single qubit.

# Fields
- `backend`: The backend used for simulation.
- `type`: The type of noise model (SingleQubit).
- `prob`: The probability of damping, can be a single value or a vector.

"""
mutable struct Damping <: NoiseModels 
    backend
    type::SingleQubit
    prob::Union{Float64,Float64,Vector{Float64},Vector{Float64}} 
end

"""
    mutable struct MixtureDensityMatrices <: NoiseModels

A mutable struct representing a mixture of density matrices noise model.

# Fields
- `backend`: The backend used for the noise model.
- `type`: The type of density matrices.
- `prob`: The probability distribution of the mixture.

"""
mutable struct MixtureDensityMatrices <: NoiseModels 
    backend
    type::DensityMatrices
    prob::Union{Float64,Float64,Vector{Float64},Vector{Float64}} 
end


"""
    struct Dephasing <: NoiseModels

Dephasing noise model that represents noise caused by dephasing errors.

# Fields
- `backend`: The backend used for simulation.
- `type`: The type of qubits affected by the noise. Can be `SingleQubit` or `TwoQubits`.
- `prob`: The probability of dephasing error. Can be a single value or a vector of probabilities.

"""
mutable struct Dephasing <: NoiseModels
    backend
    type::Union{SingleQubit,TwoQubits} 
    prob::Union{Float64,Float64,Vector{Float64},Vector{Float64}}
end


"""
    mutable struct Depolarising <: NoiseModels

A struct representing a depolarizing noise model.

# Fields
- `backend`: The backend used for the noise model.
- `type`: The type of qubits affected by the noise model.
- `prob`: The probability of depolarization, can be a single value or a vector.

"""
mutable struct Depolarising <: NoiseModels 
    backend
    type::Union{SingleQubit,TwoQubits} 
    prob::Union{Float64,Float64,Vector{Float64},Vector{Float64}} 
end


"""
    mutable struct Pauli <: NoiseModels

The `Pauli` struct represents a noise model for a single qubit. It contains the following fields:

- `backend`: The backend used for simulation.
- `type`: The type of noise model (SingleQubit).
- `prob`: The probability of each Pauli error. It can be a single value, a vector of values, or a matrix of values.

"""
mutable struct Pauli <: NoiseModels 
    backend
    type::SingleQubit
    prob::Union{Float64,Float64,Vector{Float64},Vector{Float64},Vector{Vector{Float64}},Vector{Vector{Float64}}}
end


"""
    mutable struct NoisyServer

A struct representing a noisy server.

# Fields
- `noise_model`: The noise model used by the server. It can be either a single `NoiseModels` object or a vector of `NoiseModels` objects.

"""
mutable struct NoisyServer 
    noise_model::Union{Vector{NoiseModels},NoiseModels}
end



"""
    get_noise_model(::Damping)

Get the noise model for a given damping type.

# Arguments
- `::Damping`: The damping type.

# Returns
- `add_damping!`: The noise model function.

"""
function get_noise_model(::Damping)
    add_damping!
end


"""
    get_noise_model(::Dephasing)

Get the noise model for dephasing errors.

# Arguments
- `::Dephasing`: A dephasing error model.

# Returns
- `add_dephasing!`: A function that adds dephasing errors to a quantum circuit.
"""
function get_noise_model(::Dephasing)
    add_dephasing!
end


"""
    get_noise_model(::Depolarising)

Get the noise model for the Depolarising channel.

# Arguments
- `::Depolarising`: The Depolarising channel.

# Returns
- `add_depolarising!`: The function to add depolarising noise to a quantum circuit.
"""
function get_noise_model(::Depolarising)
    add_depolarising!
end


"""
    get_noise_model(p::Pauli)

Get the noise model for a given Pauli operator.

# Arguments
- `p::Pauli`: The Pauli operator.

# Returns
- `add_pauli_noise!`: The function to add Pauli noise to a quantum circuit.
"""
function get_noise_model(::Pauli)
    add_pauli_noise!
end

"""
    get_noise_model(::Kraus)

Get the noise model for a given Kraus operator.

# Arguments
- `::Kraus`: The Kraus operator.

# Returns
- The noise model.

"""
function get_noise_model(::Kraus)
    apply_kraus_map!
end

"""
    get_noise_model(::MixtureDensityMatrices)

Get the noise model for a mixture of density matrices.

# Arguments
- `::MixtureDensityMatrices`: The mixture of density matrices.

# Returns
- The noise model.

"""
function get_noise_model(::MixtureDensityMatrices)
    mix_two_density_matrices!
end

"""
    get_noise_param(::Kraus)

Get the noise parameters for a given Kraus operator.

# Arguments
- `::Kraus`: The Kraus operator.

# Returns
- `KrausMapNoiseParameters`: The noise parameters for the Kraus operator.
"""
function get_noise_param(::Kraus)
    KrausMapNoiseParameters
end

"""
    get_noise_param(::MixtureDensityMatrices)

Get the noise parameter for a `MixtureDensityMatrices` object.

# Arguments
- `::MixtureDensityMatrices`: The input `MixtureDensityMatrices` object.

# Returns
- `MixtureDensityMatrices`: The noise parameter.

"""
function get_noise_param(::MixtureDensityMatrices)
    MixtureDensityMatrices
end

"""
    get_noise_param(noise_type)

Get the noise parameters for the specified noise type.

# Arguments
- `noise_type`: The type of noise (Damping, Dephasing, Depolarising, Pauli).

# Returns
- `QubitNoiseParameters`: The noise parameters for the specified noise type.
"""
function get_noise_param(::Union{Damping,Dephasing,Depolarising,Pauli})
    QubitNoiseParameters
end


"""
    get_noise_model_params(model::Union{Damping,Dephasing,Depolarising,Pauli}, server_qureg::Union{DensityMatrix,Qureg})

Get the noise model parameters for a given noise model and server quantum register.

# Arguments
- `model::Union{Damping,Dephasing,Depolarising,Pauli}`: The noise model to retrieve parameters for.
- `server_qureg::Union{DensityMatrix,Qureg}`: The server quantum register.

# Returns
- The noise parameters for the given noise model and server quantum register.
```
"""
function get_noise_model_params(
    model::Union{Damping,Dephasing,Depolarising,Pauli},
    server_qureg::Union{DensityMatrix,Qureg})
    qubit_type = model.type
    !(qubit_type isa SingleQubit) && 
    throw_error(OnlySingleQubitNoiseInUseError())
    noise_param = get_noise_param(model)
    qubit = 0 # get replaced with each qubit in circuit
    noise_param(server_qureg,qubit)
end



"""
    add_noise!(::NoNoise, params::NoNoiseParameters)

Add noise to the given parameters.

# Arguments
- `::NoNoise`: A type representing no noise.
- `params::NoNoiseParameters`: The parameters to add noise to.

# Returns
- `params.ρ`: The noise parameter.

"""
function add_noise!(::NoNoise, params::NoNoiseParameters)
    params.ρ
end



"""
    add_noise!(model::Union{Damping,Dephasing,Depolarising,Pauli}, params::QubitNoiseParameters)

Add noise to a quantum model based on the given noise parameters.

# Arguments
- `model::Union{Damping,Dephasing,Depolarising,Pauli}`: The quantum model to add noise to.
- `params::QubitNoiseParameters`: The noise parameters specifying the type and strength of the noise.
"""
function add_noise!(
    model::Union{Damping,Dephasing,Depolarising,Pauli},
    params::QubitNoiseParameters)
    noise_function = get_noise_model(model)
    backend = model.backend
    qubit_type = model.type
    prob = model.prob
    ρ = params.ρ
    q = params.q
    noise_function(backend,qubit_type,ρ,q,prob)
end




"""
    add_noise!(model::MixtureDensityMatrices, params::DensityMatrixMixtureParameters)

Add noise to the given `model` using the specified `params`.

# Arguments
- `model::MixtureDensityMatrices`: The mixture density matrices model.
- `params::DensityMatrixMixtureParameters`: The parameters for the density matrix mixture.
"""
function add_noise!(
    model::MixtureDensityMatrices,
    params::DensityMatrixMixtureParameters)
    noise_function = get_noise_model(model)
    backend = model.backend
    qubit_type = model.type
    ρ₁ = params.ρ₁
    ρ₂ = params.ρ₂
    p = model.prob
    noise_function(backend,qubit_type,ρ₁,ρ₂,p)
end



"""
    add_noise!(model::Kraus, params::KrausMapNoiseParameters)

Add noise to a quantum model using a specified noise function.

# Arguments
- `model::Kraus`: The quantum model to which noise will be added.
- `params::KrausMapNoiseParameters`: The parameters specifying the noise model.

```
"""
function add_noise!(
    model::Kraus,
    params::KrausMapNoiseParameters)
    noise_function = get_noise_model(model)
    backend = model.backend
    qubit_type = model.type
    trace_type = params.trace
    ρ = params.ρ
    q = params.q
    mat = params.mat
    num_ops = params.num_ops
    num_qubits = params.num_qubits
    q̂ = (q,num_qubits)
    noise_function(backend,qubit_type,trace_type,ρ,q̂,mat,num_ops)
end






