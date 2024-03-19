##################################################################
# Filename  : angles.jl
# Author    : Jonathan Miller
# Date      : 2024-03-12
# Aim       : aim_script
#           : Collect all angles and related code
#           :
##################################################################




function get_angles(angles::AbstractQuantumAngles)
    angles.angles
end


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


function compute_angle_δᵥ(::TestRound,::DummyQubit,θᵥ)
    return θᵥ
end


function compute_angle_δᵥ(::TestRound,::TrapQubit,θᵥ,rᵥ)
    return θᵥ + rᵥ*π
end



function compute_angle_δᵥ(::ComputationRound,::InputQubits,ϕ,Sx,Sz,θᵥ,rᵥ,xᵥ)
    ϕᵥ = update_ϕ(ϕ,Sx,Sz)
    δᵥ =  ϕᵥ + (θᵥ + xᵥ*π) + rᵥ*π
    return δᵥ
end


function compute_angle_δᵥ(::ComputationRound,::NoInputQubits,ϕ,Sx,Sz,θᵥ,rᵥ)
    ϕᵥ = update_ϕ(ϕ,Sx,Sz)
    δᵥ = ϕᵥ + θᵥ + rᵥ*π
    return δᵥ
end




function compute_angle_δᵥ(::Union{NoInputQubits,InputQubits},ϕ,Sx,Sz)
    return update_ϕ(ϕ,Sx,Sz)
end



function update_ϕ!(::TestRound,::DummyQubit,::NoInputQubits,meta_graph,vertex)
    θᵥ = draw_θᵥ()
    ϕ̃ = compute_angle_δᵥ(TestRound(),DummyQubit(),θᵥ)
    set_prop!(meta_graph,vertex,:updated_ϕ, ϕ̃)
    return meta_graph
end




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



function update_ϕ!(::ComputationQubit,qT::Union{NoInputQubits,InputQubits},meta_graph,vertex)
    ϕᵥ = get_prop(meta_graph,vertex,:secret_angle)
    X = get_prop(meta_graph,vertex,:X_correction)
    Z = get_prop(meta_graph,vertex,:Z_correction)
    Sx = X==0 ? 0 : get_prop(meta_graph,X,:outcome)
    Sz = []
    for z in Z
        sz = z==0 ? 0 : get_prop(meta_graph,z,:outcome)
        push!(Sz,sz)
    end
    ϕ̃ = compute_angle_δᵥ(qT,ϕᵥ,Sx,Sz) 
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






function update_init_angles!(mg::MetaGraphs.MetaGraph{Int64, Float64},is::AbstractInitialisedServer,network_type::AbstractNoNetworkEmulation) 
    mg
end
function update_init_angles!(mg::MetaGraphs.MetaGraph{Int64, Float64},is::AbstractInitialisedServer,network_type::AbstractImplicitNetworkEmulation) 
    mg
end
function update_init_angles!(mg::MetaGraphs.MetaGraph{Int64, Float64},is::AbstractInitialisedServer,network_type::AbstractBellPairExplicitNetwork) 
    qubit_types = get_qubit_types(is)
    angles = get_adapted_prep_angles(is)
    updated_angles = [
        qubit_types[x] != DummyQubit() ? angles[x] : get_prop(mg,x,:init_qubit) 
                for x in eachindex(qubit_types)]
    [set_prop!(mg,i,:init_qubit,updated_angles[i]) for i in eachindex(updated_angles)]
end

function update_init_angles!(mg::MetaGraphs.MetaGraph{Int64, Float64},is::AbstractInitialisedServer)
    network_type = get_network_type(mg)
    update_init_angles!(mg,is,network_type)
end



