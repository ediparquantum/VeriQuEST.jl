##################################################################
# Filename  : entangle.jl
# Author    : Jonathan Miller
# Date      : 2024-03-15
# Aim       : aim_script
#           : Entangle graph and hence circuit
#           :
##################################################################


function entangle_graph!(qureg,graph,qubit_range)
    edge_iter = edges(graph)
    for e in edge_iter
        src,dst = e.src,e.dst
        if src ∉ qubit_range || dst ∉ qubit_range
            continue
        elseif src ∈ qubit_range || dst ∈ qubit_range
            controlledPhaseFlip(qureg,src,dst)
        end
    end
    
end

function entangle_graph!(mg::MetaGraphs.MetaGraph{Int64, Float64},is::AbstractInitialisedServer)
    qureg = get_quantum_backend(is)
    graph = Graph(mg)
    qubit_range = get_qubit_range(is)
    entangle_graph!(qureg,graph,qubit_range)
end
















