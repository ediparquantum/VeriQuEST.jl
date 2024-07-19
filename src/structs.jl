##################################################################
# Filename  : no_fields_structs.jl
# Author    : Jonathan Miller
# Date      : 2024-03-12
# Aim       : aim_script
#           : All structs
#           :
##################################################################
struct StateVector <: AbstractStateVector end
struct DensityMatrix <: AbstractDensityMatrix end
struct ComputationRoundUniformcolouring <: AbstractComputationRoundUniformColouring end
struct TestRoundTrapAndDummycolouring <: AbstractTestRoundTrapAndDummyColouring end



struct TrapQubit <: AbstractQubitType end
struct DummyQubit <: AbstractQubitType end
struct ComputationQubit <: AbstractQubitType end


struct NoInputQubits <: AbstractInputs end
struct InputQubits  <: AbstractInputs end



struct Client <: AbstractClient end
struct Server <: AbstractServer end
struct TrustworthyServer <: AbstractServer end
struct MaliciousServer <: AbstractServer end
struct ForwardFlow <: AbstractQuantumFlow end
struct BackwardFlow <: AbstractQuantumFlow end

struct ComputationRound <: AbstractRound end
struct TestRound <: AbstractRound end
struct MBQCRound <: AbstractRound end


struct Angles <: AbstractQuantumAngles
    angles::Union{Float64,Vector{Float64}}
end

struct SecretAngles <: AbstractQuantumAngles end

struct Ok <: AbstractVerificationResults end
struct Abort <: AbstractVerificationResults end 
struct Terse <: AbstractVerificationResults end
struct Verbose <: AbstractVerificationResults end


struct TrapPass <: AbstractTestRoundTrapResults end
struct TrapFail <: AbstractTestRoundTrapResults end  


struct DummyQubitZeroOneInitialisationError <: AbstractErrors end
struct QubitFloatPhaseInitialisationError <: AbstractErrors end
struct ProbabilityExceedsOneError <: AbstractErrors end
struct ProbabilityExceedsOneHalfError <: AbstractErrors end
struct ProbabilityExceedsThreeQuartersError <: AbstractErrors end
struct ProbabilityExceedsFifteenSixteensError <: AbstractErrors end
struct ProbabilityLessThanZeroError <: AbstractErrors end
struct ProbabilityExceedsNoErrorExceededError <: AbstractErrors end
struct DimensionMismatchDensityMatricesError <: AbstractErrors end
struct OnlySingleQubitNoiseInUseError <: AbstractErrors end
struct ExceededNumKrausOperatorsError <: AbstractErrors end
struct UntestedKrausFunctionWarning <: AbstractWarnings end
struct FunctionNotMeantToBeUsedWarning <: AbstractWarnings end


struct InherentBoundedError <: AbstractQuantumComputation
    p::Float64
end




struct Quest <: AbstractQuantumComputation end
struct NoQubits <: AbstractQuantumComputation end
struct SingleQubit <: AbstractNoiseParameters end
struct TwoQubits <: AbstractNoiseParameters end
struct MultipleQubits <: AbstractNoiseParameters end 
struct DensityMatrices <: AbstractNoiseParameters end
struct TracePreserving <: AbstractNoiseParameters end
struct NotTracePreserving <: AbstractNoiseParameters end 


struct NoNoiseParameters <: AbstractNoiseParameters end

mutable struct NoiseModelParams <: AbstractNoiseParameters
    params::Union{Float64,Float64,Vector{Float64},Vector{Float64}}
end



mutable struct QubitNoiseParameters <: AbstractNoiseParameters
    ρ::Qureg
    q::Union{Nothing,Vector{Int64},Int64,Vector{Int32},Int32}
end

mutable struct DensityMatrixMixtureParameters <: AbstractNoiseParameters
    ρ₁::Qureg
    ρ₂::Qureg
end

mutable struct KrausMapNoiseParameters <: AbstractNoiseParameters
    trace::Union{TracePreserving,NotTracePreserving}
    ρ::Qureg
    q::Union{Nothing,Vector{Int64},Int64,Vector{Int32},Int32}
    mat::Matrix{ComplexF64}
    num_ops::Union{Int32,Int64}
    num_qubits::Union{Nothing,Int64}
end



mutable struct NoisyChannel  <: AbstractNoiseChannel 
    channel::Union{Vector{AbstractNoiseModels},AbstractNoiseModels}
end



mutable struct NoiseModel <: AbstractNoiseModels 
    model::AbstractSpecificNoiseModel
    params::AbstractNoiseParameters
end




struct NoNoise <: AbstractSpecificNoiseModel 
    type::NoQubits
end

struct Kraus <: AbstractSpecificNoiseModel 
    type::Union{SingleQubit,TwoQubits,MultipleQubits}
    param::Union{Missing,Any}
end

mutable struct AddBitFlip <: AbstractSpecificNoiseModel 
    type::SingleQubit
    param::Union{Float64,Float64,Vector{Float64},Vector{Float64}} 
end

mutable struct Damping <: AbstractSpecificNoiseModel 
    type::SingleQubit
    param::Union{Float64,Float64,Vector{Float64},Vector{Float64}} 
end


mutable struct MixtureDensityMatrices <: AbstractSpecificNoiseModel 
    type::DensityMatrices
    param::Union{Float64,Float64,Vector{Float64},Vector{Float64}} 
end


mutable struct Dephasing <: AbstractSpecificNoiseModel
    type::Union{SingleQubit,TwoQubits} 
    param::Union{Float64,Float64,Vector{Float64},Vector{Float64}}
end



mutable struct Depolarising <: AbstractSpecificNoiseModel 
    type::Union{SingleQubit,TwoQubits} 
    param::Union{Float64,Float64,Vector{Float64},Vector{Float64}} 
end



mutable struct Pauli <: AbstractSpecificNoiseModel 
    type::SingleQubit
    param::Union{Float64,Float64,Vector{Float64},Vector{Float64},Vector{Vector{Float64}},Vector{Vector{Float64}}}
end

mutable struct PostAngleUpdate <: AbstractSpecificNoiseModel 
    type::SingleQubit
    param::Union{Float64, Vector{Float64}}
end







