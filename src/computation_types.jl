##################################################################
# Filename  : computation_types.jl
# Author    : Jonathan Miller
# Date      : 2024-03-12
# Aim       : aim_script
#           : Different computation types
#           : 1. Measurement based quantum computation
#           : 2. Blind quantum computation
#           : 3. Leichtle verification
##################################################################






mutable struct MeasurementBasedQuantumComputation <: AbstractMeasurementBasedQuantumComputation 
    graph::AbstractQuantumGraph
    flow::AbstractQuantumFlow
    measurement_angles::AbstractQuantumAngles
end

struct BlindQuantumComputationFlag <: AbstractBlindQuantumComputation end
mutable struct BlindQuantumComputation <: AbstractBlindQuantumComputation 
    graph::AbstractQuantumGraph
    flow::AbstractQuantumFlow
    measurement_angles::AbstractQuantumAngles
end




mutable struct LeichtleVerification <: AbstractRepeatedGraphVerification 
    total_rounds::Int
    computation_rounds::Int
    trapification_strategy::AbstractTrapificationStrategy
    graph::AbstractQuantumGraph
    flow::AbstractQuantumFlow
    measurement_angles::AbstractQuantumAngles

    function LeichtleVerification(total_rounds,computation_rounds,trapification_strategy,graph,flow,measurement_angles)
        new(total_rounds,computation_rounds,trapification_strategy,graph,flow,measurement_angles)
    end

    function LeichtleVerification(total_rounds,computation_rounds,graph,flow,measurement_angles)
        new(total_rounds,computation_rounds,TestRoundTrapAndDummycolouring(),graph,flow,measurement_angles)
    end
end

function get_total_rounds(vbqc::AbstractVerifiedBlindQuantumComputation)
    vbqc.total_rounds
end

function get_num_computation_rounds(vbqc::AbstractVerifiedBlindQuantumComputation)
    vbqc.computation_rounds
end

function get_num_test_rounds(vbqc::AbstractVerifiedBlindQuantumComputation)
    get_total_rounds(vbqc) - get_num_computation_rounds(vbqc)
end

function draw_random_rounds(vbqc::AbstractVerifiedBlindQuantumComputation)
    test_rounds = get_num_test_rounds(vbqc)
    computation_rounds = get_num_computation_rounds(vbqc)
    crs = fill(ComputationRound(),computation_rounds)
    trs = fill(TestRound(),test_rounds)
    return shuffle(vcat(crs,trs))
end



function get_flow(mbqc::AbstractMeasurementBasedQuantumComputation)
    mbqc.flow
end

function set_flow!(mbqc::AbstractMeasurementBasedQuantumComputation,flow::AbstractQuantumFlow)
    mbqc.flow = flow
end

function set_backwards_flow!(computation_type::AbstractMeasurementBasedQuantumComputation)
    graph = get_graph(computation_type) |> get_graph
    flow = get_flow(computation_type)
    fflow = get_forward_flow(flow)
    backward_flow(vertex) = compute_backward_flow(graph,fflow,vertex)
    set_backward_flow!(flow,backward_flow)
    set_flow!(computation_type,flow)
end

function get_graph(mbqc::AbstractMeasurementBasedQuantumComputation)
    mbqc.graph
end

function set_graph!(mbqc::AbstractMeasurementBasedQuantumComputation,graph::AbstractQuantumGraph)
    mbqc.graph = graph
end

function get_angles(mbqc::AbstractMeasurementBasedQuantumComputation)
    mbqc.measurement_angles
end

function set_angles!(mbqc::AbstractMeasurementBasedQuantumComputation,angles::AbstractQuantumAngles)
    mbqc.measurement_angles = angles
end

function get_total_rounds(vbqc::AbstractVerifiedBlindQuantumComputation)
    vbqc.total_rounds
end

function set_total_rounds!(vbqc::AbstractVerifiedBlindQuantumComputation,total_rounds::Int)
    vbqc.total_rounds = total_rounds
end

function get_computation_rounds(vbqc::AbstractVerifiedBlindQuantumComputation)
    vbqc.computation_rounds
end

function set_computation_rounds!(vbqc::AbstractVerifiedBlindQuantumComputation,computation_rounds::Int)
    vbqc.computation_rounds = computation_rounds
end


function get_colouring(mbqc::AbstractMeasurementBasedQuantumComputation)
    get_graph(mbqc).colouring
end


struct MBQCResults <:AbstractMeasurementBasedQuantumComputation
    outcomes::Vector{Int}
end


struct UBQCResults <:AbstractBlindQuantumComputation
    outcomes::Vector{Int}
end

function get_outcomes(mbqc::MBQCResults)
    mbqc.outcomes
end

function get_outcomes(ubqc::UBQCResults)
    ubqc.outcomes
end

function get_output(mg)
    output_inds = get_prop(mg,:output_inds)
    outcome = []
    for v in output_inds
            classic_outcome = get_prop(mg,v,:outcome)
            push!(outcome,classic_outcome)
    end
    outcome
end

function get_outcome(::AbstractMeasurementBasedQuantumComputation,mg)
    outcome = get_output(mg)
    MBQCResults(outcome)
end

function get_outcome(::AbstractBlindQuantumComputation,mg)
    outcome = get_output(mg)
    UBQCResults(outcome)
end

function computation_results(mg)
    ct = get_prop(mg,:computation_type)
    get_outcome(ct,mg)
end
