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


struct ImplicitNetworkEmulation <: AbstractImplicitNetworkEmulation end
struct ExplicitNetworkEmulation <: AbstractExplicitNetworkEmulation end
struct BellPairExplicitNetwork <: AbstractExplicitNetworkEmulation end
struct NoNetworkEmulation <: AbstractNoNetworkEmulation end