abstract type NoiseModels end
abstract type NoiseParameters <: NoiseModels end
struct QubitNoiseParameters <: NoiseParameters
    backend
    type::Union{SingleQubit,TwoQubits,MultipleQubits}
    ρ::DensityMatrix
    q::Union{Vector{Int64},Int64}
    p::union{Float64,qreal,Vector{Float64},Vector{qreal}}
end

struct DensityMatrixMixtureParameters <: NoiseParameters
    backend
    ρ₁::DenseMatrix
    ρ₂::DenseMatrix
    p::union{Float64,qreal}
end

struct KrausMapNoiseParameters <: NoiseParameters
    backend
    type::Union{SingleQubit,TwoQubits,MultipleQubits}
    trace::Union{TracePreserving,NotTracePreserving}
    ρ::DensityMatrix
    q::Union{Vector{Int64},Int64}
    mat::Matrix{ComplexF64}
    num_ops::Int64
    num_qubits::Union{Nothin,Int64}
end
struct NoNoise <: NoiseModels end
struct Damping <: NoiseModels end
struct MixtureDensityMatrices <: NoiseModels end
struct Dephasing <: NoiseModels end
struct Depolarising <: NoiseModels end
struct Kraus <: NoiseModels end
struct Pauli <: NoiseModels end

function add_noise!(params::NoiseParameters)

end

function add_noise!(::Quest,::Damping,params::NoiseParameters)
    num_noisy_qubits = params[:num_noisy_qubits]
    ρ = params
    add_damping!(Quest(),num_noisy_qubits,ρ,q,p)

    struct NoiseParameters
        other_fields::Bool
        num_noisy_qubits::Union{SingleQubit,TwoQubits,MultipleQubits}
        ρ::DensityMatrix
        q::Union{Int64,Vector{Int64}}
        