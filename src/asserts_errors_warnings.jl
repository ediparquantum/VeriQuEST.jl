##################################################################
# Filename  : asserts_errors_warnings.jl
# Author    : Jonathan Miller
# Date      : 2024-03-15
# Aim       : aim_script
#           : Write function to assist in the ut
#           :
##################################################################



function assert_comment(condition,message)
    @assert condition message
end

function throw_error(::DummyQubitZeroOneInitialisationError)
    @error "Input qubit value is either a 1 or a 0, both integers, seeing this error means neither 0 or 1 integer was passed."
end

function throw_error(::QubitFloatPhaseInitialisationError)
    @error "Input qubit value is meant to be a Float64 for a plus state with a phase, seeing this error means the input value was not a Float64."
end



function throw_warning(::FunctionNotMeantToBeUsedWarning)
    @warn "This function is not meant to be used anymore, this is a generic warning message. Find out what function is throwing this issue"
end


function throw_error(::ProbabilityLessThanZeroError)
    error("Probability is less than 0 (hint: not a probability and threw an error)")
end



function throw_error(::ProbabilityExceedsOneHalfError)
    error("Probability is greater than 1/2 (hint: error thrown in relation to noise model limitations)")
end


function throw_error(::ProbabilityExceedsThreeQuartersError)
    error("Probability is greater than 3/4 (hint: error thrown in relation to noise model limitations)")
end


function throw_error(::ProbabilityExceedsFifteenSixteensError)
    error("Probability is greater than 15/16 (hint: error thrown in relation to noise model limitations)")
end



function throw_error(::ProbabilityExceedsOneError)
    error("Probability is greater than 1 (hint: not a probability and threw an error)")
end



function throw_error(::ProbabilityExceedsNoErrorExceededError)
    error("Probability is greater than no error from 1.")
end


function throw_error(::DimensionMismatchDensityMatricesError)
    error("Density matrices do not have the same dimensions")
end

function throw_error(::ExceededNumKrausOperatorsError)
    error("More Kraus operators were presented than allowed. Check again.")
end

function throw_error(::OnlySingleQubitNoiseInUseError)
    error("Two qubit or multiple qubit noise is not tested and will not be allowed to run, untill")
end

function throw_warning(::UntestedKrausFunctionWarning)
    @warn "Kraus operator is not tested, specifically transalting a pointer index from Julia to C, use at peril till function goes away"
end













