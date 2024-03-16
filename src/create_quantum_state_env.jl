
##################################################################
# Filename  : create_quantum_state_env.jl
# Author    : Jonathan Miller
# Date      : 2024-03-15
# Aim       : aim_script
#           : Create quantum state and environment
#           :
##################################################################


create_quantum_env(::Client) = createQuESTEnv()
create_quantum_env(::Server) = createQuESTEnv()

create_quantum_state(::Client,::StateVector,quantum_env,num_qubits) = createQureg(num_qubits, quantum_env)
create_quantum_state(::Client,::DensityMatrix,quantum_env,num_qubits) = createDensityQureg(num_qubits, quantum_env)
create_quantum_state(::Server,::StateVector,quantum_env,num_qubits) = createQureg(num_qubits, quantum_env)
create_quantum_state(::Server,::DensityMatrix,quantum_env,num_qubits) = createDensityQureg(num_qubits, quantum_env)


create_quantum_state(::StateVector,quantum_env,num_qubits) = createQureg(num_qubits, quantum_env)
create_quantum_state(::DensityMatrix,quantum_env,num_qubits) = createDensityQureg(num_qubits, quantum_env)

function clone_qureq(::Server,client_qureg,env)
    createCloneQureg(client_qureg, env)
end







