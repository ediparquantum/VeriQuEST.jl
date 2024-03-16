##################################################################
# Filename  : noisy_functions.jl
# Author    : Jonathan Miller
# Date      : 2024-02-12
# Aim       : aim_script
#           : Functions that are used with QuEST
#           : but are written in Julia alone.
#           : Noise models are developed here
##################################################################



get_channel(noise::AbstractNoiseChannel) = noise.channel

function get_type(noise::AbstractNoiseChannel)
    channel = get_channel(noise)
    get_type(channel)
end

function get_params(noise::AbstractNoiseChannel)
    channel = get_channel(noise)
    get_params(channel)
end


get_type(noise::AbstractNoiseModels) = noise.type
get_params(noise::Union{AbstractNoiseModels}) = noise.param
function get_params(noise::Vector{AbstractNoiseModels})
    noise
end
get_params(noise::NoiseModelParams) = noise.param



function add_bit_flip!(::SingleQubit,ρ,q,p)
    p > 1.0 && throw_error(ProbabilityExceedsOneError())
    mixBitFlip(ρ,q,p)
end


function add_damping!(::SingleQubit,ρ,q,p)
    p > 1.0 && throw_error(ProbabilityExceedsOneError())
    mixDamping(ρ,q,p)
end

function add_dephasing!(::SingleQubit,ρ,q,p)
    p > 1/2 && throw_error(ProbabilityExceedsOneHalfError())
    mixDephasing(ρ,q,p)
end 

function add_dephasing!(::TwoQubits,ρ,q,p)
    q₁,q₂ = q
    p > 3/4 && throw_error(ProbabilityExceedsThreeQuartersError())
    mixTwoQubitDephasing(ρ,q₁,q₂,p)
end 

function add_depolarising!(::SingleQubit,ρ,q,p)
    p > 3/4 && throw_error(ProbabilityExceedsThreeQuartersError())
    mixDepolarising(ρ,q,p)
end 


function add_depolarising!(::TwoQubits,ρ,q,p)
    q₁,q₂ = q
    p > 15/16 && throw_error(ProbabilityExceedsFifteenSixteensError())
    mixTwoQubitDepolarising(ρ,q₁,q₂,p)
end 


function add_pauli_noise!(::SingleQubit,ρ,q,p)
    mixPauli(ρ,q,p)
end
 

function apply_kraus_map!(::SingleQubit,::TracePreserving,ρ,q,complex_mat,num_ops)
    throw_warning(UntestedKrausFunctionWarning())
    num_ops > 4 && throw_error(ExceededNumKrausOperatorsError())
    mixKrausMap(ρ,q,complex_mat,num_ops)
end

function apply_kraus_map!(::TwoQubits,::TracePreserving,ρ,q,complex_mat,num_ops)
    throw_warning(UntestedKrausFunctionWarning())
    q₁,q₂ = q
    num_ops > 16 && throw_error(ExceededNumKrausOperatorsError())
    mixTwoQubitKrausMap(ρ,q,complex_mat,num_ops)
end

function apply_kraus_map!(::MultipleQubits,::TracePreserving,ρ,leas_sig_qubit,num_qubits,complex_mat,num_ops)
    throw_warning(UntestedKrausFunctionWarning())
    num_ops > (2*num_qubits)^2 && throw_error(ExceededNumKrausOperatorsError())
    leas_sig_qubit = q₁
    mixMultiQubitKrausMap(ρ,leas_sig_qubit,num_qubits,complex_mat,num_ops)
end



function apply_kraus_map!(::SingleQubit,::NotTracePreserving,ρ,q,complex_mat,num_ops)
    throw_warning(UntestedKrausFunctionWarning())
    num_ops > 4 && throw_error(ExceededNumKrausOperatorsError())
    mixNonTPKrausMap(ρ,q,complex_mat,num_ops)
end


function apply_kraus_map!(::TwoQubits,::NotTracePreserving,ρ,q,complex_mat,num_ops)
    throw_warning(UntestedKrausFunctionWarning())
    q₁,q₂ = q
    num_ops > 16 && throw_error(ExceededNumKrausOperatorsError())
    mixNonTPTwoQubitKrausMap(ρ,q,complex_mat,num_ops)
end


function apply_kraus_map!(::MultipleQubits,::NotTracePreserving,ρ,q,complex_mat,num_ops)
    throw_warning(UntestedKrausFunctionWarning())
    leas_sig_qubit,num_qubits = q
    num_ops > (2*num_qubits)^2 && throw_error(ExceededNumKrausOperatorsError())
    leas_sig_qubit = q₁
    mixNonTPMultiQubitKrausMap(ρ,leas_sig_qubit,num_qubits,complex_mat,num_ops)
end


function mix_two_density_matrices!(::DensityMatrices,ρ₁,ρ₂,p)
    p > 1.0 && throw_error(ProbabilityExceedsOneError())
    p < 0.0 && throw_error(ProbabilityLessThanZeroError())
    ρ₁.numQubitsRepresented == ρ₂.numQubitsRepresented && 
        throw_error(DimensionMismatchDensityMatricesError())
    mixDensityMatrix(ρ₁,p,ρ₂)
end 


function get_noise_model(::Damping)
    add_damping!
end

function get_noise_model(::Dephasing)
    add_dephasing!
end


function get_noise_model(::Depolarising)
    add_depolarising!
end


function get_noise_model(::Pauli)
    add_pauli_noise!
end

function get_noise_model(::Kraus)
    apply_kraus_map!
end

function get_noise_model(::MixtureDensityMatrices)
    mix_two_density_matrices!
end

function get_noise_param(::Kraus)
    KrausMapNoiseParameters
end

function get_noise_param(::MixtureDensityMatrices)
    MixtureDensityMatrices
end

function get_noise_param(::Union{Damping,Dephasing,Depolarising,Pauli})
    QubitNoiseParameters
end


function get_noise_model_params(
    model::Union{Damping,Dephasing,Depolarising,Pauli},
    qureg::Qureg)
    qubit_type = model.type
    !(qubit_type isa SingleQubit) && 
    throw_error(OnlySingleQubitNoiseInUseError())
    noise_param = get_noise_param(model)
    qubit = 0 # gets replaced with each qubit in circuit
    noise_param(qureg,qubit)
end


function add_noise!(::NoNoise, params::NoNoiseParameters)
    params.ρ
end



function add_noise!(
    model::Union{Damping,Dephasing,Depolarising,Pauli},
    params::QubitNoiseParameters)
    noise_function = get_noise_model(model)
    qubit_type = model.type
    prob = model.param
    ρ = params.ρ
    q = params.q
    noise_function(qubit_type,ρ,q,prob)
end



function add_noise!(
    model::MixtureDensityMatrices,
    params::DensityMatrixMixtureParameters)
    noise_function = get_noise_model(model)
    qubit_type = model.type
    ρ₁ = params.ρ₁
    ρ₂ = params.ρ₂
    p = model_param
    noise_function(qubit_type,ρ₁,ρ₂,p)
end


function add_noise!(
    model::Kraus,
    params::KrausMapNoiseParameters)
    noise_function = get_noise_model(model)
    qubit_type = model.type
    trace_type = params.trace
    ρ = params.ρ
    q = params.q
    mat = params.mat
    num_ops = params.num_ops
    num_qubits = params.num_qubits
    q̂ = (q,num_qubits)
    noise_function(qubit_type,trace_type,ρ,q̂,mat,num_ops)
end


function add_noise!(
    channel::NoisyChannel,
    qureg::Qureg)
    channel_copy = channel
    models = get_channel(channel_copy)
    if models isa Vector 
        for m in eachindex(models)
            model = models[m]
            params = get_noise_model_params(model,qureg)
            qubit_range = Base.OneTo(params.ρ.numQubitsRepresented)
            if length(model.param) == 1
                for q in qubit_range
                    params.q = q
                    add_noise!(model,params)
                end
            elseif length(model.param) > 1
                probs = model.param
                for q in qubit_range
                    model.param = probs[q]
                    params.q = q
                    add_noise!(model,params)
                end
            end
        end
    elseif !(models isa Vector)
        params = get_noise_model_params(models,qureg)
        qubit_range = Base.OneTo(params.ρ.numQubitsRepresented)
        if length(models.param) == 1
            for q in qubit_range
                params.q = q
                add_noise!(models,params)
            end
        elseif length(models.param) > 1
            probs = model.param
            for q in qubit_range
                models.param = probs[q]
                params.q = q
                add_noise!(models,params)
            end
        
        end
    end
end


function add_noise!(channel::NoisyChannel,is::AbstractInitialisedServer)
    qureg = get_quantum_backend(is)
    add_noise!(channel,qureg)
end