##################################################################
# Filename  : run_quantum_computation.jl
# Author    : Jonathan Miller
# Date      : 2024-03-13
# Aim       : aim_script
#           : Run quantum computation scripts
#           :
##################################################################


 function run_computation!(
    mg::MetaGraphs.MetaGraph{Int64, Float64},
    channel::NoisyChannel,::Union{Damping,Dephasing,Depolarising,PostAngleUpdate,Vector{AbstractNoiseModels}})
    initialised_server = get_prop(mg,:quantum_state_properties)
    qubits_to_measure = get_qubit_range(initialised_server)
    for q in qubits_to_measure  
        adjusted_qubit = adjust_vertex(mg,q)
        ϕ̃ = get_updated_ϕ!(Client(),mg,adjusted_qubit)
        ϕ = add_noise!(Client(),mg,channel,adjusted_qubit,ϕ̃)
        m̃ = measure_along_ϕ_basis!(Server(),mg,q,ϕ)
        m̂ = update_measurement(Client(),mg,adjusted_qubit,m̃)
        m = add_noise!(Client(),mg,channel,adjusted_qubit,m̂)
        store_measurement_outcome!(Client(),mg,adjusted_qubit,m)
    end
    mg
end


function run_computation!(
    mg::MetaGraphs.MetaGraph{Int64, Float64},channel::NoisyChannel,
    ::NoNoise)
    initialised_server = get_prop(mg,:quantum_state_properties)
    qubits_to_measure = get_qubit_range(initialised_server)
    for q in qubits_to_measure  
        adjusted_qubit = adjust_vertex(mg,q)
        ϕ = get_updated_ϕ!(Client(),mg,adjusted_qubit)
        m̃ = measure_along_ϕ_basis!(Server(),mg,q,ϕ)
        m = update_measurement(Client(),mg,adjusted_qubit,m̃)
        store_measurement_outcome!(Client(),mg,adjusted_qubit,m)
    end
    mg
end



function run_computation!(
    mg::MetaGraphs.MetaGraph{Int64, Float64},channel::NoisyChannel,
    ::AddBitFlip)
    initialised_server = get_prop(mg,:quantum_state_properties)
    qubits_to_measure = get_qubit_range(initialised_server)
    for q in qubits_to_measure  
        adjusted_qubit = adjust_vertex(mg,q)
        ϕ = get_updated_ϕ!(Client(),mg,adjusted_qubit)
        m̃ = measure_along_ϕ_basis!(Server(),mg,q,ϕ)
        m̂ = update_measurement(Client(),mg,adjusted_qubit,m̃)
        m = add_noise!(Client(),mg,channel,adjusted_qubit,m̂)
        store_measurement_outcome!(Client(),mg,adjusted_qubit,m)
    end
    mg
end

function run_computation!(mg::MetaGraphs.MetaGraph{Int64, Float64},channel::NoisyChannel)
    model = get_channel(channel)
    run_computation!(mg,channel,model)
end


function reset_quantum_state!(quantum_state::Qureg)
    initBlankState(quantum_state)
end

function reset_quantum_state!(mg::MetaGraphs.MetaGraph{Int64, Float64})
    initialised_server = get_prop(mg,:quantum_state_properties)
    qureg = get_quantum_backend(initialised_server)
    initZeroState(qureg)
end