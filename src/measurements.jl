##################################################################
# Filename  : update_measurement.jl
# Author    : Jonathan Miller
# Date      : 2024-03-15
# Aim       : aim_script
#           : Update measurement
#           :
##################################################################


# UBQC/VBQC
function update_measurement(::Client,::ComputationRound,q,mg,outcome)
    one_time_pad_int = get_prop(mg,q,:one_time_pad_int)
    abs(outcome-one_time_pad_int)	
end
# MBQC/Test round
function update_measurement(::Client,::TestRound,q,mg,outcome)
    outcome
end

function update_measurement(::Client,q,mg,outcome)
    RT = get_prop(mg,:round_type)
    update_measurement(Client(),RT,q,mg,outcome)
end



function measure_along_ϕ_basis!(::Client,ψ,v::Union{Int32,Int64},ϕ::Float64)
    rotateZ(ψ,v,-ϕ)
    hadamard(ψ,v)
    measure(ψ,v)
end


function measure_along_ϕ_basis!(::MaliciousServer,ψ,v::Union{Int32,Int64},ϕ::Float64)
    rotateZ(ψ,v,-ϕ)
    hadamard(ψ,v)
    measure(ψ,v)
end





function measure_along_ϕ_basis!(::Union{Server,NoisyChannel},ψ,v::Union{Int32,Int64},ϕ::Union{Float64,Float64})
    rotateZ(ψ,v,-ϕ)
    hadamard(ψ,v)
    measure(ψ,v)
end

