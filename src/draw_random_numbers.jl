##################################################################
# Filename  : draw_random_numbers.jl
# Author    : Jonathan Miller
# Date      : 2024-03-15
# Aim       : House a selection of functions used to draw random 
#           : number and angles
#           :
##################################################################


draw_bit() = rand([0,1])
rand_k_0_7() = rand(0:7)
draw_θᵥ() = rand_k_0_7()*π/4.0
draw_rᵥ() = draw_bit()
draw_dᵥ() = draw_bit()



