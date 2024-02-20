##################################################################
# Filename  : client_random_draw_functions_angle_bits.jl
# Author    : Jonathan Miller
# Date      : 2023-08-25
# Aim       : House a selection of functions used to draw random 
#           : number and angles
#           :
##################################################################






"""
    draw_bit()

Draw a random bit, either 0 or 1. This function uses the `rand` function to randomly select from the array `[0,1]`.

# Returns
- A random bit, either 0 or 1.

# Examples
```julia
draw_bit() # Outputs: 0 or 1
```
"""
draw_bit() = rand([0,1])


"""
    rand_k_0_7()

Draw a random integer between 0 and 7, inclusive. This function uses the `rand` function to randomly select from the range `0:7`.

# Returns
- A random integer between 0 and 7, inclusive.

# Examples
```julia
rand_k_0_7() # Outputs: An integer between 0 and 7
```
"""
rand_k_0_7() = rand(0:7)


"""
    draw_θᵥ()

Draw a random angle θ that is a multiple of kπ/4, where k is an integer between 0 and 7, inclusive. This function uses the `rand_k_0_7` function to select k, and then calculates θ.

# Returns
- A random angle θ that is a multiple of kπ/4.

# Examples
```julia
draw_θᵥ() # Outputs: A multiple of π/4 between 0 and 7π/4
```
"""
draw_θᵥ() = rand_k_0_7()*π/4.0



"""
    draw_rᵥ()

Draw a random bit, either 0 or 1, for a trap. This function uses the `draw_bit` function to select the bit.

# Returns
- A random bit, either 0 or 1, for a trap.

# Examples
```julia
draw_rᵥ() # Outputs: 0 or 1
```
"""
draw_rᵥ() = draw_bit()



"""
    draw_dᵥ()

Draw a random bit, either 0 or 1, for a dummy. This function uses the `draw_bit` function to select the bit.

# Returns
- A random bit, either 0 or 1, for a dummy.

# Examples
```julia
draw_dᵥ() # Outputs: 0 or 1
````
"""
draw_dᵥ() = draw_bit()



