##################################################################
# Filename  : entangle.jl
# Author    : Jonathan Miller
# Date      : 2024-03-15
# Aim       : aim_script
#           : Entangle graph and hence circuit
#           :
##################################################################



function entangle_graph!(::BellPairExplicitNetwork,qureg,graph)
    edge_iter = edges(graph)
    max_qubit = qureg.numQubitsRepresented
    for e in edge_iter
        src,dst = e.src+1,e.dst+1 # qureg client is shifted by 1
        @assert src ≤ max_qubit || dst ≤ max_qubit "Either vertex $(src) or $(dst) is greater than $(max_qubit), which is the largest index for the quantum state, fix."
        controlledPhaseFlip(qureg,src,dst)
    end
end


function entangle_graph!(::Union{AbstractImplicitNetworkEmulation,AbstractNoNetworkEmulation},qureg,graph)
    edge_iter = edges(graph)
    max_qubit = qureg.numQubitsRepresented
    for e in edge_iter
        src,dst = e.src,e.dst 
        @assert src ≤ max_qubit || dst ≤ max_qubit "Either vertex $(src) or $(dst) is greater than $(max_qubit), which is the largest index for the quantum state, fix."
        controlledPhaseFlip(qureg,src,dst)
    end
end


function entangle_graph!(mg::MetaGraphs.MetaGraph{Int64, Float64},is::AbstractInitialisedServer)
    qureg = get_quantum_backend(is)
    graph = Graph(mg)
    nt = get_prop(mg,:network_type) 
    entangle_graph!(nt,qureg,graph)
end
















