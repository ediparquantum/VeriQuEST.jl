##################################################################
# Filename  : update_measurement.jl
# Author    : Jonathan Miller
# Date      : 2024-03-15
# Aim       : aim_script
#           : Update measurement
#           :
##################################################################

function measure_along_ϕ_basis!(::Server,ψ::Qureg,v::Union{Int,Int32,Int64},ϕ::Float64)
    QuEST.rotateZ(ψ,v,-ϕ)
    QuEST.hadamard(ψ,v)
    QuEST.measure(ψ,v)
end

function measure_along_ϕ_basis!(::Server,mg::MetaGraphs.MetaGraph{Int64, Float64},q::Union{Int,Int32,Int64},ϕ::Float64)
    initialised_server = get_prop(mg,:quantum_state_properties)
    ψ = get_quantum_backend(initialised_server)
    measure_along_ϕ_basis!(Server(),ψ,q,ϕ)
end


# MBQC
function update_measurement(::Client,::MBQCRound,::AbstractNoNetworkEmulation,mg::MetaGraphs.MetaGraph{Int64, Float64},q::Union{Int,Int32,Int64},outcome::Union{Int,Int32,Int64})
    outcome
end

# UBQC/VBQC
function update_measurement(::Client,::ComputationRound,::AbstractImplicitNetworkEmulation,mg::MetaGraphs.MetaGraph{Int64, Float64},q::Union{Int,Int32,Int64},outcome::Union{Int,Int32,Int64})
    one_time_pad_int = get_prop(mg,q,:one_time_pad_int)
    abs(outcome-one_time_pad_int)	
end

function update_measurement(::Client,::ComputationRound,::AbstractBellPairExplicitNetwork,mg::MetaGraphs.MetaGraph{Int64, Float64},q::Union{Int,Int32,Int64},outcome::Union{Int,Int32,Int64})
    one_time_pad_int = get_prop(mg,q,:one_time_pad_int)
    abs(outcome-one_time_pad_int)	
end
# MBQC/Test round
function update_measurement(::Client,::TestRound,::Union{AbstractImplicitNetworkEmulation,AbstractBellPairExplicitNetwork},mg::MetaGraphs.MetaGraph{Int64, Float64},q::Union{Int,Int32,Int64},outcome::Union{Int,Int32,Int64})
    outcome
end



function update_measurement(::Client,mg::MetaGraphs.MetaGraph{Int64, Float64},q::Union{Int,Int32,Int64},outcome::Union{Int,Int32,Int64})
    round_type = get_prop(mg,:round_type)
    network_type = get_prop(mg,:network_type)
    update_measurement(Client(),round_type,network_type,mg,q,outcome)
end













