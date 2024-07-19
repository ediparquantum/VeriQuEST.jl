##################################################################
# Filename  : abstract_types.jl
# Author    : Jonathan Miller
# Date      : 2024-03-12
# Aim       : aim_script
#           : Collate all abstract types
#           :
##################################################################



abstract type AbstractQuantumComputation end
abstract type AbstractMessages end

abstract type AbstractClient <: AbstractQuantumComputation end
abstract type AbstractServer <: AbstractQuantumComputation end
abstract type AbstractGateBasedQuantumComputation <: AbstractQuantumComputation end
abstract type AbstractMeasurementBasedQuantumComputation <: AbstractQuantumComputation end
abstract type AbstractQuantumState <: AbstractQuantumComputation end
abstract type AbstractQuantumColouring <: AbstractQuantumComputation end
abstract type AbstractParameterResources <: AbstractQuantumComputation end
abstract type AbstractNetworkEmulation <: AbstractQuantumComputation end
abstract type AbstractQubitType <: AbstractQuantumComputation end
abstract type AbstractRound <: AbstractQuantumComputation end
abstract type AbstractErrors <: AbstractMessages end
abstract type AbstractWarnings <: AbstractMessages end
abstract type AbstractComment <: AbstractMessages end

abstract type AbstractBlindQuantumComputation <: AbstractMeasurementBasedQuantumComputation end
abstract type AbstractVerifiedBlindQuantumComputation <: AbstractMeasurementBasedQuantumComputation end
abstract type AbstractQuantumGraph <: AbstractMeasurementBasedQuantumComputation end
abstract type AbstractQuantumFlow <: AbstractMeasurementBasedQuantumComputation end
abstract type AbstractInputs <: AbstractMeasurementBasedQuantumComputation end
abstract type AbstractOutputs <: AbstractMeasurementBasedQuantumComputation end
abstract type AbstractInputOutputs <: AbstractMeasurementBasedQuantumComputation end
abstract type AbstractQuantumAngles <: AbstractMeasurementBasedQuantumComputation end




abstract type AbstractStateVector <: AbstractQuantumState end
abstract type AbstractDensityMatrix <: AbstractQuantumState end


abstract type AbstractTrapificationStrategy <: AbstractQuantumColouring end
abstract type AbstractComputationColouring <: AbstractQuantumColouring end
abstract type AbstractTestColouring <: AbstractQuantumColouring end



abstract type AbstractComputationRoundUniformColouring <: AbstractTrapificationStrategy end
abstract type AbstractTestRoundTrapAndDummyColouring <: AbstractTrapificationStrategy end


abstract type AbstractRepeatedGraphVerification <: AbstractVerifiedBlindQuantumComputation end
abstract type AbstractExpandedGraphVerification <: AbstractVerifiedBlindQuantumComputation end


abstract type AbstractNoNetworkEmulation <: AbstractNetworkEmulation end
abstract type AbstractImplicitNetworkEmulation <:AbstractNetworkEmulation end
abstract type AbstractExplicitNetworkEmulation <:AbstractNetworkEmulation end
abstract type AbstractBellPairExplicitNetwork <:AbstractExplicitNetworkEmulation end
abstract type AbstractInitialisedServer <: AbstractNetworkEmulation end


abstract type AbstractQuantumNoise <: AbstractQuantumComputation end
abstract type AbstractNoiseChannel <: AbstractQuantumNoise end
abstract type AbstractNoiseModels <: AbstractNoiseChannel end
abstract type AbstractSpecificNoiseModel <: AbstractNoiseModels end
abstract type AbstractNoiseParameters <: AbstractNoiseModels end



abstract type AbstractVerificationResults <: AbstractVerifiedBlindQuantumComputation end
abstract type AbstractTestRoundTrapResults <: AbstractVerificationResults end






