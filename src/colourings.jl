##################################################################
# Filename  : colourings.jl
# Author    : Jonathan Miller
# Date      : 2024-03-12
# Aim       : aim_script
#           : All colouring related code
#           :
##################################################################

mutable struct ComputationColouring <: AbstractComputationColouring
    colours::Vector{Int64}
    function ComputationColouring()
        new(Int[])
    end
    function ComputationColouring(colours::Vector{Int64})
        new(colours)
    end
end



mutable struct TestColouring <: AbstractTestColouring
    colours::Vector{Vector{Int64}}
    function TestColouring()
        new([Int[]])
    end
    function TestColouring(colours::Vector{Vector{Int64}})
        new(colours)
    end
end



mutable struct QuantumColouring <: AbstractQuantumColouring
    computation_round::AbstractComputationColouring
    test_round::AbstractTestColouring
    function QuantumColouring()
        new(ComputationColouring(), TestColouring())
    end
    function QuantumColouring(computation_round::Vector{Int64},test_round::Vector{Vector{Int64}})
        new(ComputationColouring(computation_round),TestColouring(test_round))
    end

    function QuantumColouring(computation_round::AbstractComputationColouring,test_round::AbstractTestColouring)
        new(computation_round,test_round)
    end

    function QuantumColouring(computation_round::AbstractComputationColouring)
        new(computation_round,TestColouring())
    end

    function QuantumColouring(test_round::AbstractTestColouring)
        new(ComputationColouring(),test_round)
    end
end





function get_colouring(::AbstractComputationColouring,colouring::AbstractQuantumColouring)
    colouring.computation_round
end

function get_colouring(::AbstractTestColouring,colouring::AbstractQuantumColouring)
    colouring.test_round
end

function get_colouring(colouring::AbstractComputationColouring)
    colouring.colours
end

function get_colouring(colouring::AbstractTestColouring)
    colouring.colours
end



function generate_random_greedy_color(g,reps)
    return Graphs.random_greedy_color(g, reps)
end


function separate_each_color(g::Graphs.Coloring{Int64})
    colouring = map(x-> Int.(g.colors .== x).+1,Base.OneTo(g.num_colors))
    return colouring
end

function get_vector_graph_colors(graph;reps=100)
    g_cols = generate_random_greedy_color(graph,reps)        
    separate_each_color(g_cols)
end

function get_random_coloring(c::Vector{Vector{Int64}})
    return rand(c)
end




