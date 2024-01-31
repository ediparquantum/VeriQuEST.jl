##################################################################
# Filename  : client_random_draw_functions_angle_bits.jl
# Author    : Jonathan Miller
# Date      : 2023-08-25
# Aim       : House a selection of functions used to draw random 
#           : number and angles
#           :
##################################################################
"""
    Draw random bit 0 or 1
"""
draw_bit() = rand([0,1])

"""
    Draw random interger between 0 and 7
"""
rand_k_0_7() = rand(0:7)

"""
    For draw θ a multiple of kπ/4, k ∈ 0..7
"""
draw_θᵥ() = rand_k_0_7()*π/4.0

"""
    Draw random bit 0 or 1 for trap
"""
draw_rᵥ() = draw_bit()

"""
    Draw random bit 0 or 1 for dummy
"""
draw_dᵥ() = draw_bit()



