##################################################################
# Filename  : client_update_angle.jl
# Author    : Jonathan Miller
# Date      : 2023-08-25
# Aim       : Angle update function
#           : Used in standard MBQC
#           : Used in UBQC and Verification
##################################################################








"""
    update_ϕ(ϕ, Sx, Sz)

Base function to update the angle `ϕ` based on the values of `Sx` and `Sz`.

# Arguments
- `ϕ`: The current angle.
- `Sx`: The value of Sx.
- `Sz`: An array of values representing Sz.

# Returns
- The updated angle.

# Examples
```julia
julia> update_ϕ(0, 0, [0, 0, 0])
0
```
"""
# Base function to update angle 
function update_ϕ(ϕ,Sx,Sz)
    #return (-1)^Sx*ϕ + π*sum(Sz)
    return (-1)^Sx*ϕ + π*mod(sum(Sz),2)
end





#=
Computation of δᵥ
Cases
1. Round ≡ Test ∩ Qubit ≡ Dummy
    → δᵥ = {kπ/r | k ∼ U(0..7)}
2. Round ≡ Test ∩ Qubit ≡ Trap
    → δᵥ = θᵥ + rᵥπ
3. Round ≡ Computation ∩ Qubit ∈ Input set
    → δᵥ = ϕᵥ + (θᵥ + xᵥπ) + rᵥπ
4. Roiund ≡ Computation ∩ Qubiut ∉ Input set
    → δᵥ = ϕᵥ′ + θᵥ + rᵥπ
=#




"""
Computation of δᵥ

This function computes the angle δᵥ based on the given parameters.

Arguments:
- ::TestRound: The test round object.
- ::DummyQubit: The dummy qubit object.
- θᵥ: The input angle.

Returns:
- δᵥ: The computed angle δᵥ.

Case:
1. Round ≡ Test ∩ Qubit ≡ Dummy
    → δᵥ = {kπ/r | k ∼ U(0..7)}

# Examples
```julia    
julia> compute_angle_δᵥ(TestRound(),DummyQubit(),0)
0
```
"""
function compute_angle_δᵥ(::TestRound,::DummyQubit,θᵥ)
    return θᵥ
end


"""
    compute_angle_δᵥ(::TestRound, ::TrapQubit, θᵥ, rᵥ)

Compute the angle δᵥ for the case where the round is a test round and the qubit is a trap qubit.

Computation of δᵥ
Case
2. Round ≡ Test ∩ Qubit ≡ Trap
    → δᵥ = θᵥ + rᵥπ

# Arguments
- `::TestRound`: The type representing a test round.
- `::TrapQubit`: The type representing a trap qubit.
- `θᵥ`: The angle θᵥ.
- `rᵥ`: The coefficient rᵥ.

# Returns
The computed angle δᵥ.

# Example
```julia
julia> compute_angle_δᵥ(TestRound(), TrapQubit(), 0, 0)
0
```
"""
function compute_angle_δᵥ(::TestRound,::TrapQubit,θᵥ,rᵥ)
    return θᵥ + rᵥ*π
end




"""
Computation of δᵥ

This function computes the value of δᵥ based on the given parameters.

Case
3. Round ≡ Computation ∩ Qubit ∈ Input set
    → δᵥ = ϕᵥ + (θᵥ + xᵥπ) + rᵥπ

Arguments:
- `::ComputationRound`: The computation round.
- `::InputQubits`: The input qubits.
- `ϕ`: The value of ϕ.
- `Sx`: The value of Sx.
- `Sz`: The value of Sz.
- `θᵥ`: The value of θᵥ.
- `rᵥ`: The value of rᵥ.
- `xᵥ`: The value of xᵥ.

Returns:
- `δᵥ`: The computed value of δᵥ.

# Examples
```julia
julia> compute_angle_δᵥ(ComputationRound(),InputQubits(),0,0,[0,0,0],0,0,0)
0
```
"""
function compute_angle_δᵥ(::ComputationRound,::InputQubits,ϕ,Sx,Sz,θᵥ,rᵥ,xᵥ)
    ϕᵥ = update_ϕ(ϕ,Sx,Sz)
    δᵥ =  ϕᵥ + (θᵥ + xᵥ*π) + rᵥ*π
    return δᵥ
end





"""
    compute_angle_δᵥ(::ComputationRound,::NoInputQubits,ϕ,Sx,Sz,θᵥ,rᵥ)

Compute the angle δᵥ based on the given parameters.

Computation of δᵥ
Case
4. Round ≡ Computation ∩ Qubit ∉ Input set
    → δᵥ = ϕᵥ′ + θᵥ + rᵥπ

# Arguments
- `::ComputationRound`: The computation round.
- `::NoInputQubits`: The number of input qubits.
- `ϕ`: The value of ϕ.
- `Sx`: The value of Sx.
- `Sz`: The value of Sz.
- `θᵥ`: The value of θᵥ.
- `rᵥ`: The value of rᵥ.

# Returns
- `δᵥ`: The computed angle δᵥ.

# Example
```julia
julia> compute_angle_δᵥ(ComputationRound(),NoInputQubits(),0,0,[0,0,0],0,0)
0
```
"""
function compute_angle_δᵥ(::ComputationRound,::NoInputQubits,ϕ,Sx,Sz,θᵥ,rᵥ)
    ϕᵥ = update_ϕ(ϕ,Sx,Sz)
    δᵥ = ϕᵥ + θᵥ + rᵥ*π
    return δᵥ
end




"""
    compute_angle_δᵥ(mbqc, qubits, ϕ, Sx, Sz)

Compute the angle δᵥ for the given MBQC, qubits, ϕ, Sx, and Sz.

# Arguments
- `mbqc`: The MBQC object.
- `qubits`: The qubits object, either `NoInputQubits` or `InputQubits`.
- `ϕ`: The angle ϕ.
- `Sx`: The Sx value.
- `Sz`: The Sz value.

# Returns
- The updated angle δᵥ.

# Example
```julia
julia> compute_angle_δᵥ(MBQC(), NoInputQubits(), 0, 0, [0, 0, 0])
0
```
"""
function compute_angle_δᵥ(::MBQC,::Union{NoInputQubits,InputQubits},ϕ,Sx,Sz)
    return update_ϕ(ϕ,Sx,Sz)
end




"""
    update_ϕ!(::TestRound, ::DummyQubit, ::NoInputQubits, meta_graph, vertex)

Updates the ϕ value of a given vertex in the `meta_graph` during a test round with a dummy qubit and no input qubits. The new ϕ value is computed based on a randomly drawn θᵥ value.

# Arguments
- `::TestRound`: Indicates that this function is used during a test round.
- `::DummyQubit`: Indicates that a dummy qubit is used.
- `::NoInputQubits`: Indicates that there are no input qubits.
- `meta_graph`: The graph to be updated.
- `vertex`: The vertex in the graph for which the ϕ value is to be updated.

# Returns
- The updated `meta_graph`.

# Examples
```julia
updated_graph = update_ϕ!(TestRound(), DummyQubit(), NoInputQubits(), meta_graph, vertex) # Updates the ϕ value of the specified vertex in the graph
```
"""
function update_ϕ!(::TestRound,::DummyQubit,::NoInputQubits,meta_graph,vertex)
    θᵥ = draw_θᵥ()
    ϕ̃ = compute_angle_δᵥ(TestRound(),DummyQubit(),θᵥ)
    set_prop!(meta_graph,vertex,:updated_ϕ, ϕ̃)
    return meta_graph
end

"""
    update_ϕ!(::TestRound, ::TrapQubit, ::NoInputQubits, meta_graph, vertex)

Updates the ϕ value of a given vertex in the `meta_graph` during a test round with a trap qubit and no input qubits. The new ϕ value is computed based on the initial qubit θᵥ and a randomly drawn rᵥ value.

# Arguments
- `::TestRound`: Indicates that this function is used during a test round.
- `::TrapQubit`: Indicates that a trap qubit is used.
- `::NoInputQubits`: Indicates that there are no input qubits.
- `meta_graph`: The graph to be updated.
- `vertex`: The vertex in the graph for which the ϕ value is to be updated.

# Returns
- The updated `meta_graph`.

# Examples
```julia
updated_graph = update_ϕ!(TestRound(), TrapQubit(), NoInputQubits(), meta_graph, vertex) # Updates the ϕ value of the specified vertex in the graph
```
"""
function update_ϕ!(::TestRound,::TrapQubit,::NoInputQubits,meta_graph,vertex)
    θᵥ = get_prop(meta_graph,vertex,:init_qubit)
    rᵥ = draw_rᵥ()
    ϕ̃ = compute_angle_δᵥ(TestRound(),TrapQubit(),θᵥ,rᵥ)
    set_prop!(meta_graph,vertex,:updated_ϕ, ϕ̃)
    set_prop!(meta_graph,vertex,:one_time_pad_int, rᵥ)
    return meta_graph
end


function update_ϕ!(::ComputationRound,::ComputationQubit,::InputQubits,meta_graph,vertex)
    θᵥ = get_prop(meta_graph,vertex,:init_qubit)
    ϕᵥ = get_prop(meta_graph,vertex,:secret_angle)
    rᵥ = draw_rᵥ()
    xᵥ = get_prop(meta_graph,vertex,:classic_input)
    X = get_prop(meta_graph,vertex,:X_correction)
    Z = get_prop(meta_graph,vertex,:Z_correction)
    Sx = X==0 ? 0 : get_prop(meta_graph,X,:outcome)
    Sz = []
    for z in Z
        sz = z==0 ? 0 : get_prop(meta_graph,z,:outcome)
        push!(Sz,sz)
    end
    ϕ̃ = compute_angle_δᵥ(ComputationRound(),InputQubits(),ϕᵥ,Sx,Sz,θᵥ,rᵥ,xᵥ)
    set_prop!(meta_graph,vertex,:updated_ϕ, ϕ̃)
    set_prop!(meta_graph,vertex,:one_time_pad_int, rᵥ)

end



function update_ϕ!(::ComputationRound,::ComputationQubit,::NoInputQubits,meta_graph,vertex)
    θᵥ = get_prop(meta_graph,vertex,:init_qubit)
    ϕᵥ = get_prop(meta_graph,vertex,:secret_angle)
    rᵥ = draw_rᵥ()
    X = get_prop(meta_graph,vertex,:X_correction)
    Z = get_prop(meta_graph,vertex,:Z_correction)
    Sx = X==0 ? 0 : get_prop(meta_graph,X,:outcome)
    Sz = []
    for z in Z
        sz = z==0 ? 0 : get_prop(meta_graph,z,:outcome)
        push!(Sz,sz)
    end
    ϕ̃ = compute_angle_δᵥ(ComputationRound(),NoInputQubits(),ϕᵥ,Sx,Sz,θᵥ,rᵥ)
    set_prop!(meta_graph,vertex,:updated_ϕ, ϕ̃)
    set_prop!(meta_graph,vertex,:one_time_pad_int, rᵥ)
end

function update_ϕ!(::MBQC,::ComputationQubit,qT::Union{NoInputQubits,InputQubits},meta_graph,vertex)
    ϕᵥ = get_prop(meta_graph,vertex,:secret_angle)
    X = get_prop(meta_graph,vertex,:X_correction)
    Z = get_prop(meta_graph,vertex,:Z_correction)
    Sx = X==0 ? 0 : get_prop(meta_graph,X,:outcome)
    Sz = []
    for z in Z
        sz = z==0 ? 0 : get_prop(meta_graph,z,:outcome)
        push!(Sz,sz)
    end
    ϕ̃ = compute_angle_δᵥ(MBQC(),qT,ϕᵥ,Sx,Sz) 
    set_prop!(meta_graph,vertex,:updated_ϕ, ϕ̃)
end


function get_updated_ϕ!(RountType,QubitType,QubitIOType,client_meta_graph,qubit)
    update_ϕ!(RountType,QubitType,QubitIOType,client_meta_graph,qubit)
    get_prop(client_meta_graph,qubit,:updated_ϕ)
end



function get_updated_ϕ!(::Client,mg,qubit)
    round_type = get_prop(mg,:round_type)
    v_type = get_prop(mg,qubit,:vertex_type)
    v_io_type = get_prop(mg,qubit,:vertex_io_type)
    get_updated_ϕ!(round_type,v_type,v_io_type,mg,qubit)
end





