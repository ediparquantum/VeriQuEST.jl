# Permute rounds to be test of computation
function draw_random_rounds(total_rounds,computation_rounds)
    test_rounds = total_rounds - computation_rounds
    crs = fill(ComputationRound(),computation_rounds)
    trs = fill(TestRound(),test_rounds)
    return shuffle(vcat(crs,trs))
end



function is_round_OK(trap_results)
    # At least one trap result is 0 (failed)
    failed_traps = filter(x->x==0,trap_results)
    !(length(failed_traps) >= 1)
end