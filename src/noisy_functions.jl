abstract type NoiseModels end
abstract type NoiseParameters <: NoiseModels end
struct NoNoiseParameters <: NoiseParameters end
struct QubitNoiseParameters <: NoiseParameters
    backend
    type::Union{SingleQubit,TwoQubits,MultipleQubits}
    ρ::Union{DensityMatrix,QuEST_jl.QuEST64.QuEST_Types.Qureg}
    q::Union{Vector{Int64},Int64}
    p::Union{Float64,qreal,Vector{Float64},Vector{qreal}}
end

struct DensityMatrixMixtureParameters <: NoiseParameters
    backend
    type::DensityMatrices
    ρ₁::Union{DensityMatrix,QuEST_jl.QuEST64.QuEST_Types.Qureg}
    ρ₂::Union{DensityMatrix,QuEST_jl.QuEST64.QuEST_Types.Qureg}
    p::Union{Float64,qreal}
end

struct KrausMapNoiseParameters <: NoiseParameters
    backend
    type::Union{SingleQubit,TwoQubits,MultipleQubits}
    trace::Union{TracePreserving,NotTracePreserving}
    ρ::Union{DensityMatrix,QuEST_jl.QuEST64.QuEST_Types.Qureg}
    q::Union{Vector{Int64},Int64}
    mat::Matrix{ComplexF64}
    num_ops::Int64
    num_qubits::Union{Nothing,Int64}
end
struct NoNoise <: NoiseModels end
struct Damping <: NoiseModels end
struct MixtureDensityMatrices <: NoiseModels end
struct Dephasing <: NoiseModels end
struct Depolarising <: NoiseModels end
struct Kraus <: NoiseModels end
struct Pauli <: NoiseModels end



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


function add_noise!(::NoNoise,params::NoNoiseParameters)
    params.ρ
end

function add_noise!(
    model::Union{Damping,Dephasing,Depolarising,Pauli},
    params::QubitNoiseParameters)

    noise_function = get_noise_model(model)
    backend = params.backend
    qubit_type = params.type
    ρ = params.ρ
    q = params.q
    p = params.p
    noise_function(backend,qubit_type,ρ,q,p)
end




function add_noise!(
    model::MixtureDensityMatrices,
    params::DensityMatrixMixtureParameters)

    noise_function = get_noise_model(model)
    backend = params.backend
    qubit_type = params.type
    ρ₁ = params.ρ₁
    ρ₂ = params.ρ₂
    p = params.p
    noise_function(backend,qubit_type,ρ₁,ρ₂,p)
end



function add_noise!(
    model::Kraus,
    params::KrausMapNoiseParameters)

    noise_function = get_noise_model(model)
    backend = params.backend
    qubit_type = params.type
    trace_type = params.trace
    ρ = params.ρ
    q = params.q
    mat = params.mat
    num_ops = params.num_ops
    num_qubits = params.num_qubits
    q̂ = (q,num_qubits)
    noise_function(backend,qubit_type,trace_type,ρ,q̂,mat,num_ops)
end



  




