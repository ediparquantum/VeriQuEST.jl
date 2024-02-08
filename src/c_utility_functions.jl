##################################################################
# Filename  : c_utility_functions.jl
# Author    : Jonathan Miller
# Date      : 2023-07-07
# Aim       : aim_script
#           : Collection of functions to aid in the use of
#           : C based programs in Julia
##################################################################

"""
    c_shift_index(n::Int)

    Compute the shifted index `n-1` for circular indexing.

    # Arguments
    
    - `n::Int`: The input index.

    # Returns
    The shifted index `n-1` for circular indexing.

    # Examples

    ```julia
    # Compute the shifted index
    n = 3
    shifted_index = c_shift_index(n)
    ```

"""
function c_shift_index(n)
    n -= 1
end


"""
    c_iterator(N)

    Create a circular iterator that generates numbers from 0 to `N-1`.

    # Arguments
    - `N`: The upper limit for the circular iterator.

    # Returns
    A circular iterator that generates numbers from 0 to `N-1`.

    # Examples
    ```julia
    # Create a circular iterator
    N = 5
    iterator = c_iterator(N)
    ```

"""
function c_iterator(N)
    iter = Iterators.countfrom(0, 1)
    return Iterators.takewhile(<(N), iter)
end




