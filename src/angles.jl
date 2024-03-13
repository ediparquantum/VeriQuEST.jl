##################################################################
# Filename  : angles.jl
# Author    : Jonathan Miller
# Date      : 2024-03-12
# Aim       : aim_script
#           : Collect all angles and related code
#           :
##################################################################


struct Angles <: AbstractQuantumAngles
    angles::Union{Float64,Vector{Float64}}
end

function get_angles(angles::AbstractQuantumAngles)
    angles.angles
end