##################################################################
# Filename  : trapification_strategies.jl
# Author    : Jonathan Miller
# Date      : 2024-03-12
# Aim       : aim_script
#           : All trapification strategies
#           :
##################################################################


function get_uniform_colouring(qc::AbstractMeasurementBasedQuantumComputation)
    graph = get_graph(qc) |> get_graph # gets quantum graph, then get underlying graph
    computation_colours = Int.(ones(nv(graph)))
    ComputationColouring(computation_colours)
end

function get_test_colouring(qc::AbstractMeasurementBasedQuantumComputation)
    graph = get_graph(qc) |> get_graph # gets quantum graph, then get underlying graph
    reps = 100
    test_colours = get_vector_graph_colors(graph;reps=reps)
    TestColouring(test_colours)
end

function get_colouring(mbqc::MeasurementBasedQuantumComputation) 
    QuantumColouring(get_uniform_colouring(mbqc))
end

function get_colouring(ubqc::AbstractBlindQuantumComputation)
    QuantumColouring(get_uniform_colouring(ubqc))
end

function get_colouring(vbqc::AbstractVerifiedBlindQuantumComputation)
    computation_colours = get_uniform_colouring(vbqc)
    test_colours = get_test_colouring(vbqc)
    QuantumColouring(computation_colours,test_colours)
end

function get_trapification_strategy(vbqc::AbstractVerifiedBlindQuantumComputation)
    vbqc.trapification_strategy
end

function get_colouring(lvbqc::LeichtleVerification,strategy::TestRoundTrapAndDummycolouring)
    computation_colours = get_uniform_colouring(lvbqc)
    test_colours = get_test_colouring(lvbqc)
    QuantumColouring(computation_colours,test_colours)
end

function get_colouring(lvbqc::LeichtleVerification)
    strategy = get_trapification_strategy(lvbqc)
    get_colouring(lvbqc,strategy)
end

function set_colouring!(mbqc::AbstractMeasurementBasedQuantumComputation)
    mbqc.graph.colouring = get_colouring(mbqc)
end



