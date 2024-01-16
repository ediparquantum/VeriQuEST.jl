struct Quest end
struct SingleQubit end
struct TwoQubits end
struct MultipleQubits end 
struct DensityMatrices end
struct TracePreserving end
struct NotTracePreserving end 
struct ProbabilityExceedsOneError end
struct ProbabilityExceedsOneHalfError end
struct ProbabilityExceedsThreeQuartersError end
struct ProbabilityExceedsFifteenSixteensError end
struct ProbabilityLessThanZeroError end
struct ProbabilityExceedsNoErrorExceeded end
struct DimensionMismatchDensityMatrices end
struct ExceededNumKrausOperators end
struct UntestedKrausFunction end
struct OnlySingleQubitNoiseInUseError end

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

function throw_error(::ProbabilityExceedsNoErrorExceeded)
    error("Probability is greater than no error from 1.")
end


function throw_error(::DimensionMismatchDensityMatrices)
    error("Density matrices do not have the same dimensions")
end


function throw_error(::ExceededNumKrausOperators)
    error("More Kraus operators were presented than allowed. Check again.")
end

function throw_error(::OnlySingleQubitNoiseInUseError)
    error("Two qubit or multiple qubit noise is not tested and will not be allowed to run, untill")
end

function throw_warning(::UntestedKrausFunction)
    @warn "Kraus operator is not tested, specifically transalting a pointer index from Julia to C, use at peril till function goes away"
end

function add_damping!(::Quest,::SingleQubit,ρ,q,p)
    p > 1.0 && throw_error(ProbabilityExceedsOneError())
    #q = c_shift_index(q)
    mixDamping(ρ,q,p)
end



function add_dephasing!(::Quest,::SingleQubit,ρ,q,p)
    p > 1/2 && throw_error(ProbabilityExceedsOneHalfError())
    #q = c_shift_index(q)
    mixDephasing(ρ,q,p)
end 


function add_dephasing!(::Quest,::TwoQubits,ρ,q,p)
    q₁,q₂ = q
    p > 3/4 && throw_error(ProbabilityExceedsThreeQuartersError())
    #q₁ = c_shift_index(q₁)
    #q₂ = c_shift_index(q₂)
    mixTwoQubitDephasing(ρ,q₁,q₂,p)
end 


function add_depolarising!(::Quest,::SingleQubit,ρ,q,p)
    p > 3/4 && throw_error(ProbabilityExceedsThreeQuartersError())
    #q = c_shift_index(q)
    mixDepolarising(ρ,q,p)
end 

function add_depolarising!(::Quest,::TwoQubits,ρ,q,p)
    q₁,q₂ = q
    p > 15/16 && throw_error(ProbabilityExceedsFifteenSixteensError())
    #q₁ = c_shift_index(q₁)
    #q₂ = c_shift_index(q₂)
    mixTwoQubitDepolarising(ρ,q₁,q₂,p)
end 

function add_pauli_noise!(::Quest,::SingleQubit,ρ,q,p)
    px,py,pz = p
    prob_no_error = 1 - px - py - pz
    px > prob_no_error && throw_error(ProbabilityExceedsNoErrorExceeded())
    py > prob_no_error && throw_error(ProbabilityExceedsNoErrorExceeded())
    pz > prob_no_error && throw_error(ProbabilityExceedsNoErrorExceeded())
    #q =  c_shift_index(q)
    mixPauli(ρ,q,px,py,pz)
end
 
function apply_kraus_map!(::Quest,::SingleQubit,::TracePreserving,ρ,q,complex_mat,num_ops)
    throw_warning(UntestedKrausFunction())
    num_ops > 4 && throw_error(ExceededNumKrausOperators())
    #q = c_shift_index(q)
    mixKrausMap(ρ,q,complex_mat,num_ops)
end
function apply_kraus_map!(::Quest,::TwoQubits,::TracePreserving,ρ,q,complex_mat,num_ops)
    throw_warning(UntestedKrausFunction())
    q₁,q₂ = q
    num_ops > 16 && throw_error(ExceededNumKrausOperators())
    #q₁ = c_shift_index(q₁)
    #q₂ = c_shift_index(q₂)
    mixTwoQubitKrausMap(ρ,q,complex_mat,num_ops)
end
function apply_kraus_map!(::Quest,::MultipleQubits,::TracePreserving,ρ,leas_sig_qubit,num_qubits,complex_mat,num_ops)
    throw_warning(UntestedKrausFunction())
    num_ops > (2*num_qubits)^2 && throw_error(ExceededNumKrausOperators())
    leas_sig_qubit = q₁#c_shift_index(q₁)
    mixMultiQubitKrausMap(ρ,leas_sig_qubit,num_qubits,complex_mat,num_ops)
end

function apply_kraus_map!(::Quest,::SingleQubit,::NotTracePreserving,ρ,q,complex_mat,num_ops)
    throw_warning(UntestedKrausFunction())
    num_ops > 4 && throw_error(ExceededNumKrausOperators())
    #q = c_shift_index(q)
    mixNonTPKrausMap(ρ,q,complex_mat,num_ops)
end

function apply_kraus_map!(::Quest,::TwoQubits,::NotTracePreserving,ρ,q,complex_mat,num_ops)
    throw_warning(UntestedKrausFunction())
    q₁,q₂ = q
    num_ops > 16 && throw_error(ExceededNumKrausOperators())
    #q₁ = c_shift_index(q₁)
    #q₂ = c_shift_index(q₂)
    mixNonTPTwoQubitKrausMap(ρ,q,complex_mat,num_ops)
end


function apply_kraus_map!(::Quest,::MultipleQubits,::NotTracePreserving,ρ,q,complex_mat,num_ops)
    throw_warning(UntestedKrausFunction())
    leas_sig_qubit,num_qubits = q
    num_ops > (2*num_qubits)^2 && throw_error(ExceededNumKrausOperators())
    leas_sig_qubit = q₁#c_shift_index(q₁)
    mixNonTPMultiQubitKrausMap(ρ,leas_sig_qubit,num_qubits,complex_mat,num_ops)
end



 
function mix_two_density_matrices!(::Quest,::DensityMatrices,ρ₁,ρ₂,p)
    p > 1.0 && throw_error(ProbabilityExceedsOneError())
    p < 0.0 && throw_error(ProbabilityLessThanZeroError())
    ρ₁.numQubitsRepresented == ρ₂.numQubitsRepresented && 
        throw_error(DimensionMismatchDensityMatrices())
    mixDensityMatrix(ρ₁,p,ρ₂)
end 