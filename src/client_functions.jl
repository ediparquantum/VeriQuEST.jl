
create_quantum_state(::Client,::StateVector,quantum_env,num_qubits) = QuEST.createQureg(num_qubits, quantum_env)
create_quantum_state(::Client,::DensityMatrix,quantum_env,num_qubits) = QuEST.createDensityQureg(num_qubits, quantum_env)



