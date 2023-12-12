

abstract type NoiseModels end
abstract type NoiseParameters <: NoiseModels end
struct NoNoiseParameters <: NoiseParameters end
mutable struct NoiseModel <: NoiseModels 
    model
    params::NoiseParameters
end

mutable struct NoiseModelParams <: NoiseParameters
    prob::Union{Float64,qreal,Vector{Float64},Vector{qreal}}
end
mutable struct QubitNoiseParameters <: NoiseParameters
    ρ::Union{DensityMatrix,QuEST_jl.QuEST64.QuEST_Types.Qureg}
    q::Union{Nothing,Vector{Int64},Int64,Vector{Int32},Int32}
end

mutable struct DensityMatrixMixtureParameters <: NoiseParameters
    ρ₁::Union{DensityMatrix,QuEST_jl.QuEST64.QuEST_Types.Qureg}
    ρ₂::Union{DensityMatrix,QuEST_jl.QuEST64.QuEST_Types.Qureg}
end

mutable struct KrausMapNoiseParameters <: NoiseParameters
    trace::Union{TracePreserving,NotTracePreserving}
    ρ::Union{DensityMatrix,QuEST_jl.QuEST64.QuEST_Types.Qureg}
    q::Union{Nothing,Vector{Int64},Int64,Vector{Int32},Int32}
    mat::Matrix{ComplexF64}
    num_ops::Union{Int32,Int64}
    num_qubits::Union{Nothing,Int64}
end
struct NoNoise <: NoiseModels 
    backend
end
struct Kraus <: NoiseModels 
    backend
    type::Union{SingleQubit,TwoQubits,MultipleQubits}
end
mutable struct Damping <: NoiseModels 
    backend
    type::SingleQubit
    prob::Union{Float64,qreal,Vector{Float64},Vector{qreal}} 
end
mutable struct MixtureDensityMatrices <: NoiseModels 
    backend
    type::DensityMatrices
    prob::Union{Float64,qreal,Vector{Float64},Vector{qreal}} 
end
mutable struct Dephasing <: NoiseModels
    backend
    type::Union{SingleQubit,TwoQubits} 
    prob::Union{Float64,qreal,Vector{Float64},Vector{qreal}}
end
mutable struct Depolarising <: NoiseModels 
    backend
    type::Union{SingleQubit,TwoQubits} 
    prob::Union{Float64,qreal,Vector{Float64},Vector{qreal}} 
end

mutable struct Pauli <: NoiseModels 
    backend
    type::SingleQubit
    prob::Union{Float64,qreal,Vector{Float64},Vector{qreal},Vector{Vector{Float64}},Vector{Vector{qreal}}}
end

mutable struct NoisyServer 
    noise_model::Union{Vector{NoiseModels},NoiseModels}
end

function get_noise_model(::Damping)
    add_damping!
end


function get_noise_model(::Dephasing)
    add_dephasing!
end


function get_noise_model(::Depolarising)
    add_depolarising!
end


function get_noise_model(::Pauli)
    add_pauli_noise!
end

function get_noise_model(::Kraus)
    apply_kraus_map!
end

function get_noise_model(::MixtureDensityMatrices)
    mix_two_density_matrices!
end

function get_noise_param(::Kraus)
    KrausMapNoiseParameters
end

function get_noise_param(::MixtureDensityMatrices)
    MixtureDensityMatrices
end

function get_noise_param(::Union{Damping,Dephasing,Depolarising,Pauli})
    QubitNoiseParameters
end


function get_noise_model_params(
    model::Union{Damping,Dephasing,Depolarising,Pauli},
    server_qureg::Union{DensityMatrix,QuEST_jl.QuEST64.QuEST_Types.Qureg})
    qubit_type = model.type
    !(qubit_type isa SingleQubit) && 
    throw_error(OnlySingleQubitNoiseInUseError())
    noise_param = get_noise_param(model)
    qubit = 0 # get replaced with each qubit in circuit
    noise_param(server_qureg,qubit)
end

function add_noise!(::NoNoise,params::NoNoiseParameters)
    params.ρ
end

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






