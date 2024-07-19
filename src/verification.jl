##################################################################
# Filename  : verification_functions.jl
# Author    : Jonathan Miller
# Date      : 2024-03-15
# Aim       : aim_script
#           : Verification functions
#           :
##################################################################

struct VerificationResults <: AbstractVerificationResults
    tests::AbstractVerificationResults
    computations::AbstractVerificationResults
    tests_verbose::NamedTuple
    computations_verbose::NamedTuple
    computations_mode::AbstractArray
end
get_tests(vr::VerificationResults) = vr.tests
get_computations(vr::VerificationResults) = vr.computations
get_tests_verbose(vr::VerificationResults) = vr.tests_verbose
get_computations_verbose(vr::VerificationResults) = vr.computations_verbose
get_computations_mode(vr::VerificationResults) = vr.computations_mode



function is_round_OK(trap_results)
    # At least one trap result is 0 (failed)
    failed_traps = filter(x->x==0,trap_results)
    !(length(failed_traps) >= 1)
end

function compute_trap_round_fail_threshold(total_rounds,computational_rounds,number_different_test_rounds,inherent_bounded_error::InherentBoundedError) 
    t = total_rounds - computational_rounds #number of test rounds
    k,p = number_different_test_rounds,inherent_bounded_error.p
    floor((t/k)*(2*p - 1)/(2*p - 2))
end

function compute_trap_round_fail_threshold(
    ct::AbstractVerifiedBlindQuantumComputation)
    t = get_num_test_rounds(ct)
    k = get_chromatic_number(ct)
    p = InherentBoundedError(1/3).p
    floor((t/k)*(2*p - 1)/(2*p - 2))
end


function get_output(::Client,::ComputationRound,mg)
    output_inds = get_prop(mg,:output_inds)
    outcome = []
    for v in output_inds
            classic_outcome = get_prop(mg,v,:outcome)
            push!(outcome,classic_outcome)
    end
    outcome
end



function verify_round(::Client,::TestRound,mg)
    trap_results = []
    for v in vertices(mg)
        v_type = get_prop(mg,v,:vertex_type)
        if v_type isa TrapQubit
            neighs = all_neighbors(mg,v)
            bᵥ = get_prop(mg,v,:outcome)
            rᵥ = get_prop(mg,v,:one_time_pad_int)
            Dₙ = []
            for n in neighs
                n_type = get_prop(mg,n,:vertex_type)
                @assert n_type isa DummyQubit "Neighbour of a trap is not a dummy, check."
                dₙ = get_prop(mg,n,:init_qubit)
                push!(Dₙ,dₙ)
            end
            ver_res = mod(sum(reduce(vcat,[bᵥ,rᵥ,Dₙ])),2) == 0
            trap_res = ver_res ? TrapPass() : TrapFail()
            push!(trap_results,trap_res)
        end
    end
    # 1 the round is good, 0 the round is bad
    all([t isa TrapPass for t in trap_results]) ? 1 : 0
end



function verify_rounds(::Client,::TestRound,::Terse,rounds_as_graphs,pass_theshold)
      
    outcomes = []
    for mg in rounds_as_graphs
        get_prop(mg,:round_type) == ComputationRound() && continue
        push!(outcomes,verify_round(Client(),TestRound(),mg))
    end

    failed_rounds = count(==(0),outcomes)
    return failed_rounds > pass_theshold ? Abort() : Ok()
end


function verify_rounds(::Client,::TestRound,::Verbose,rounds_as_graphs,pass_theshold)
      
    outcomes = []
    for mg in rounds_as_graphs
        get_prop(mg,:round_type) == ComputationRound() && continue
        push!(outcomes,verify_round(Client(),TestRound(),mg))
    end
    num_rounds = length(outcomes)

    failed_rounds = count(==(0),outcomes)
    return (failed = failed_rounds,passed = num_rounds - failed_rounds)
end


function verify_rounds(::Client,::ComputationRound,::Terse,rounds_as_graphs)
    num_computation_rounds = [
        get_prop(mg,:round_type) == ComputationRound() ? 1 : nothing
            for mg in rounds_as_graphs] |>
        x-> filter(!isnothing,x) |>
        length
    
    outputs = []
    for mg in rounds_as_graphs
        get_prop(mg,:round_type) == TestRound() && continue
        push!(outputs,get_output(Client(),ComputationRound(),mg))
    end

    mod_res = mode(outputs)
    num_match_mode = count(==(mod_res),outputs)

    num_match_mode > num_computation_rounds/2 ? Ok() : Abort()
end

function verify_rounds(::Client,::ComputationRound,::Verbose,rounds_as_graphs)
    num_computation_rounds = [
        get_prop(mg,:round_type) == ComputationRound() ? 1 : nothing
            for mg in rounds_as_graphs] |>
        x-> filter(!isnothing,x) |>
        length
    
    outputs = []
    for mg in rounds_as_graphs
        get_prop(mg,:round_type) == TestRound() && continue
        push!(outputs,get_output(Client(),ComputationRound(),mg))
    end
    num_rounds = length(outputs)


    mod_res = mode(outputs)
    num_match_mode = count(==(mod_res),outputs)
    return (failed = num_rounds - num_match_mode, passed = num_match_mode)
end

function get_mode_output(::Client,::ComputationRound,rounds_as_graphs::Vector)

    outputs = []
    for mg in rounds_as_graphs
        get_prop(mg,:round_type) == TestRound() && continue
        push!(outputs,get_output(Client(),ComputationRound(),mg))
    end

   mode(outputs)
end


function run_verification(
    ct::AbstractVerifiedBlindQuantumComputation,
    nt::AbstractNetworkEmulation,
    st::AbstractQuantumState,
    ch::AbstractNoiseChannel,
    rt::Vector{AbstractRound})
nt isa AbstractNoNetworkEmulation && error("Verification requires a network emulation, not $(nt)")

round_graphs = []
for round_type in rt
    computation_output = compute!(ct,nt,st,ch,round_type)
    push!(round_graphs,computation_output)
end

round_graphs
end


function run_verification_simulator(
    ct::AbstractMeasurementBasedQuantumComputation,
    nt::AbstractNetworkEmulation,
    st::AbstractQuantumState,
    ch::AbstractNoiseChannel)


    test_rounds_theshold = compute_trap_round_fail_threshold(ct)
    round_types = draw_random_rounds(ct)
    rounds_as_graphs = run_verification(ct,nt,st,ch,round_types)

    test_verification = verify_rounds(Client(),TestRound(),Terse(),rounds_as_graphs,test_rounds_theshold)
    computation_verification = verify_rounds(Client(),ComputationRound(),Terse(),rounds_as_graphs)
    mode_outcome = get_mode_output(Client(),ComputationRound(),rounds_as_graphs)
    test_verification_verb = verify_rounds(Client(),TestRound(),Verbose(),rounds_as_graphs,test_rounds_theshold)
    computation_verification_verb = verify_rounds(Client(),ComputationRound(),Verbose(),rounds_as_graphs)
    return VerificationResults(
            test_verification,
            computation_verification,
            test_verification_verb,
            computation_verification_verb,
            mode_outcome)

end






