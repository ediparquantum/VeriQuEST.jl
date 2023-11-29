abstract type NoiseModels end
abstract type NoiseParameters <: NoiseModels end
struct NoNoiseParameters <: NoiseParameters end
mutable struct NoiseModel <: NoiseModels 
    model
    params::NoiseParameters
end
mutable struct QubitNoiseParameters <: NoiseParameters
    backend
    ρ::Union{DensityMatrix,QuEST_jl.QuEST64.QuEST_Types.Qureg}
    q::Union{Nothing,Vector{Int64},Int64,Vector{Int32},Int32}
end

mutable struct DensityMatrixMixtureParameters <: NoiseParameters
    backend
    ρ₁::Union{DensityMatrix,QuEST_jl.QuEST64.QuEST_Types.Qureg}
    ρ₂::Union{DensityMatrix,QuEST_jl.QuEST64.QuEST_Types.Qureg}
end

mutable struct KrausMapNoiseParameters <: NoiseParameters
    backend
    trace::Union{TracePreserving,NotTracePreserving}
    ρ::Union{DensityMatrix,QuEST_jl.QuEST64.QuEST_Types.Qureg}
    q::Union{Nothing,Vector{Int64},Int64,Vector{Int32},Int32}
    mat::Matrix{ComplexF64}
    num_ops::Union{Int32,Int64}
    num_qubits::Union{Nothing,Int64}
end
struct NoNoise <: NoiseModels end
struct Kraus <: NoiseModels 
    type::Union{SingleQubit,TwoQubits,MultipleQubits}
end
mutable struct Damping <: NoiseModels 
    type::SingleQubit
    prob::Union{Float64,qreal,Vector{Float64},Vector{qreal}} 
end
mutable struct MixtureDensityMatrices <: NoiseModels 
    type::DensityMatrices
    prob::Union{Float64,qreal,Vector{Float64},Vector{qreal}} 
end
mutable struct Dephasing <: NoiseModels
    type::Union{SingleQubit,TwoQubits} 
    prob::Union{Float64,qreal,Vector{Float64},Vector{qreal}}
end
mutable struct Depolarising <: NoiseModels 
    type::Union{SingleQubit,TwoQubits} 
    prob::Union{Float64,qreal,Vector{Float64},Vector{qreal}} 
end

mutable struct Pauli <: NoiseModels 
    type::SingleQubit
    prob::Union{Float64,qreal,Vector{Float64},Vector{qreal}}
end

function length(noise_model::Union{Vector{NoiseModel},NoiseModel})
    noise_model isa Vector && return length(noise_model)
    !(noise_model isa Vector) && return 1
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

function add_noise!(::NoNoise,params::NoNoiseParameters)
    params.ρ
end

function add_noise!(
    model::Union{Damping,Dephasing,Depolarising,Pauli},
    params::QubitNoiseParameters)
    noise_function = get_noise_model(model)
    backend = params.backend
    qubit_type = model.type
    ρ = params.ρ
    q = params.q
    p = model.prob
    noise_function(backend,qubit_type,ρ,q,p)
end




function add_noise!(
    model::MixtureDensityMatrices,
    params::DensityMatrixMixtureParameters)
    noise_function = get_noise_model(model)
    backend = params.backend
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
    backend = params.backend
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






