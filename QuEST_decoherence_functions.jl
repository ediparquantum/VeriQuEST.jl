struct Quest end
struct SingleQubit end
struct TwoQubits end
struct MultipleQubits end 
struct TracePreserving end
struct NotTracePreserving end 
struct ProbabilityExceedsOneError end
struct ProbabilityLessThanZeroError end
struct DimensionMismatchDensityMatrices end

function throw_error(::ProbabilityExceedsOneError)
    error("Probability is greater than 1 (hint: not a probability and threw an error)")
end

function throw_error(::ProbabilityLessThanZeroError)
    error("Probability is less than 0 (hint: not a probability and threw an error)")
end

function throw_error(::DimensionMismatchDensityMatrices)
    error("Density matrices do not have the same dimensions")
end




function add_damping!(::Quest,ρ,q,p)
    p > 1.0 && throw_error(ProbabilityExceedsOneError())
    q = c_shift_index(q)
    QuEST.mixDamping(ρ,q,p)
end


function mix_two_density_matrices!(::Quest,ρ₁,ρ₂,p)
    p > 1.0 && throw_error(ProbabilityExceedsOneError())
    p < 0.0 && throw_error(ProbabilityLessThanZeroError())
    ρ₁.numQubitsRepresented == ρ₂.numQubitsRepresented && 
        throw_error(DimensionMismatchDensityMatrices())
    QuEST.mixDensityMatrix(ρ₁,p,ρ₂)
end 

function add_dephasing(::Quest,::SingleQubit)
end 
function add_dephasing(::Quest,::TwoQubits)
end 
void mixDephasing(Qureg qureg, int targetQubit, qreal prob)
Mixes a density matrix qureg to induce single-qubit dephasing noise. More...

void mixTwoQubitDephasing(Qureg qureg, int qubit1, int qubit2, qreal prob)
Mixes a density matrix qureg to induce two-qubit dephasing noise. More...

function add_depolarising(::Quest,::SingleQubit)
end 

function add_depolarising(::Quest,::TwoQubits)
end 

void mixDepolarising(Qureg qureg, int targetQubit, qreal prob)
Mixes a density matrix qureg to induce single-qubit homogeneous depolarising noise. More...

void mixTwoQubitDepolarising(Qureg qureg, int qubit1, int qubit2, qreal prob)
Mixes a density matrix qureg to induce two-qubit homogeneous depolarising noise. More...



 
function apply_kraus_map(::Quest,::SingleQubit,::TracePreserving)
end
function apply_kraus_map(::Quest,::TwoQubits,::TracePreserving)
end
function apply_kraus_map(::Quest,::MultipleQubits,::TracePreserving)
end
function apply_kraus_map(::Quest,::SingleQubit,::NotTracePreserving)
end
function apply_kraus_map(::Quest,::TwoQubits,::NotTracePreserving)
end
function apply_kraus_map(::Quest,::MultipleQubits,::NotTracePreserving)
end

 

 
void mixKrausMap(Qureg qureg, int target, ComplexMatrix2 *ops, int numOps)
Apply a general single-qubit Kraus map to a density matrix, as specified by at most four Kraus operators, 
(ops). More...
 
void mixTwoQubitKrausMap(Qureg qureg, int target1, int target2, ComplexMatrix4 *ops, int numOps)
Apply a general two-qubit Kraus map to a density matrix, as specified by at most sixteen Kraus operators. More...

void mixMultiQubitKrausMap(Qureg qureg, int *targets, int numTargets, ComplexMatrixN *ops, int numOps)
Apply a general N-qubit Kraus map to a density matrix, as specified by at most(2N)^2 Kraus operators. More...
 
void mixNonTPKrausMap(Qureg qureg, int target, ComplexMatrix2 *ops, int numOps)
Apply a general non-trace-preserving single-qubit Kraus map to a density matrix, as specified by at most four operators, 
(ops). More...
 
void mixNonTPMultiQubitKrausMap(Qureg qureg, int *targets, int numTargets, ComplexMatrixN *ops, int numOps)
Apply a general N-qubit non-trace-preserving Kraus map to a density matrix, as specified by at most(2N)^2 operators. More...
 
void mixNonTPTwoQubitKrausMap(Qureg qureg, int target1, int target2, ComplexMatrix4 *ops, int numOps)
Apply a general non-trace-preserving two-qubit Kraus map to a density matrix, as specified by at most sixteen operators, 
(ops). More...
 
function add_pauli_noise(::Quest,::SingleQubit)
void mixPauli(Qureg qureg, int targetQubit, qreal probX, qreal probY, qreal probZ)
Mixes a density matrix qureg to induce general single-qubit Pauli noise. More...
end
 

 
Detailed mixDepolarising