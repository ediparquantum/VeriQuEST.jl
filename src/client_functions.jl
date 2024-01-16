


create_quantum_env(::Client) = createQuESTEnv()
create_quantum_state(::Client,::StateVector,quantum_env,num_qubits) = createQureg(num_qubits, quantum_env)
create_quantum_state(::Client,::DensityMatrix,quantum_env,num_qubits) = createDensityQureg(num_qubits, quantum_env)


function update_measurement(::Client,::ComputationRound,q,mg,outcome)
    one_time_pad_int = get_prop(mg,q,:one_time_pad_int)
    abs(outcome-one_time_pad_int)	
end

function update_measurement(::Client,::Union{MBQC,TestRound},q,mg,outcome)
    outcome
end

function update_measurement(::Client,q,mg,outcome)
    RT = get_prop(mg,:round_type)
    update_measurement(Client(),RT,q,mg,outcome)
end

struct NoisyClient 
    noise_model::Union{Vector{NoiseModel},NoiseModel}
end

function add_noise!(
    ::Client,
    model::Union{Damping,Dephasing,Depolarising,Pauli},
    params::QubitNoiseParameters)
    !(params.type isa SingleQubit) && throw_error(OnlySingleQubitNoiseInUseError())
    qubit_range = Base.OneTo(params.backend.numQubitsRepresented)
    for q in qubit_range
        params.q = q
        add_noise!(model,params)
    end
end

function add_noise!(
    ::Client,noise_model::NoiseModel)
    add_noise!(noise_model)
end

