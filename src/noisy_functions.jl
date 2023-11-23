abstract type NoiseModels end
abstract type NoiseParameters <: NoiseModels end
struct NoNoiseParameters <: NoiseParameters end
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


function add_noise!(model::NoNoise,params::NoNoiseParameters)

end
function add_noise!(model::Damping,params::QubitNoiseParameters)

end
function add_noise!(model::MixtureDensityMatrices,params::DensityMatrixMixtureParameters)

end
function add_noise!(model::Dephasing,params::QubitNoiseParameters)

end
function add_noise!(model::Kraus,params::KrausMapNoiseParameters)

end
function add_noise!(model::Depolarising,params::QubitNoiseParameters)

end
function add_noise!(model::Pauli,params::QubitNoiseParameters)

end
