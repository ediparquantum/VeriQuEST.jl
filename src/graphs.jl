##################################################################
# Filename  : graphs.jl
# Author    : Jonathan Miller
# Date      : 2024-03-12
# Aim       : aim_script
#           : Collect all grphs and related code
#           :
##################################################################






mutable struct QuantumGraph <: AbstractQuantumGraph
    graph::AbstractGraph
    io::AbstractInputOutputs
    colouring::AbstractQuantumColouring
    function QuantumGraph(graph,io)
        # need compuration colouring 
        # need test colourings

        new(graph,io,QuantumColouring())
    end

    function QuantumGraph(graph,io,colouring)
        new(graph,io,colouring)
    end
end

function get_graph(graph::AbstractQuantumGraph)
    graph.graph
end

function get_io(graph::AbstractQuantumGraph)
    graph.io
end

function get_colouring(graph::AbstractQuantumGraph)
    graph.colouring
end