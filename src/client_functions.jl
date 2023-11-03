
create_quantum_state(::Client,::StateVector,quantum_env,num_qubits) = QuEST.createQureg(num_qubits, quantum_env)
create_quantum_state(::Client,::DensityMatrix,quantum_env,num_qubits) = QuEST.createDensityQureg(num_qubits, quantum_env)


function update_measurement(::Client,::ComputationRound,q,mg,outcome)
    one_time_pad_int = get_prop(mg,q,:one_time_pad_int)
    abs(outcome-one_time_pad_int)	
end

function update_measurement(::Client,::TestRound,q,mg,outcome)
    outcome
end

function update_measurement(::Client,q,mg,outcome)
    RT = get_prop(mg,:round_type)
    update_measurement(Client(),RT,q,mg,outcome)
end

