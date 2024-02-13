# Getting started 

Recall the generic template to get started.

```julia
# Choose backend and round counts
state_type::DensityMatrix = DensityMatrix() #or StateVector
total_rounds::Int = # Number of rounds, 1...N
computation_rounds::Int = # Number of rounds,1,...,N

# Grover graph
num_vertices::Int = # Also becomes number of qubits
graph = Graph(num_vertices)::Graph # Uses Graphs.jl
# Specify graph using Graphs.jl API

input = (indices = (),values = ())::NamedTuple # Input classical data
output = ()::Tuple # Output qubits classical outcomes BQP 

# Julia is indexed 1, hence a vertex with 0 index is a flag for no flow
function forward_flow(vertex::Int)
    v_str = string(vertex)
    forward = Dict(
        "current" =>future,
        "1" => 0) # indicates vertex 1 does not have a flow, specify all qubits. 
    forward[v_str]
end


secret_angles::Vector{Float64} = # Angles secret from Bob


# Keep as is
para::NamedTuple= (
    graph=graph,
    forward_flow = forward_flow,
    input = input,
    output = output,
    secret_angles=secret_angles,
    state_type = state_type,
    total_rounds = total_rounds,
    computation_rounds = computation_rounds)
```
## Using `para`

### Basic computation

To simply run the algorithm, unblinded, then call `run_mbqc`

```julia
run_mbqc(para)
```
and for a blind computation of the same input, then call `run_ubqc`

```julia
run_ubqc(para)
```

Since both are computing the same graph, except that `run_ubqc` hides the state and both are universal, then the outcome should be the same.

### Verification

#### Trustworthy

To run the verification of a noiseless and trustworthy server.

```julia
vbqc_outcome = run_verification_simulator(TrustworthyServer(),Verbose(),para)
```

Note that additionally to `para`, there are two type calls, `TrustWorthyServer` and `Verbose`. Due to Julia's use of multiple dispatch, algorithms make use of this paradigm. In this case `Trustworthy` indicates there is no noise and no maliciousness. And the flag `Verbose` retuns more lengthy result data, as opposed to the `Terse` type.

```julia
vbqc_outcome = run_verification_simulator(TrustworthyServer(),Terse(),para)
```

#### Malicious

Here malicious is implemented as an additionaly angle the server adds to each qubit's measurement angle.

For the `Verbose` outcome

```julia
 malicious_angles = π/2
malicious_vbqc_outcome = run_verification_simulator(MaliciousServer(),Verbose(),para,malicious_angles)
```

For the `Terse` outcome


#### Noisyness

From QuEST, there are pre-built decoherence emulators.

##### Single qubit

Damping, dephasing, depolarising and pauli noise models have been implemented and tested. Note there are also Kraus maps, but testing is in development.

To run a noisy verification, call the same `run_verification_simulaor`, but this time the server is a `NoisyServer` which has a noise model. A noise model is called, which is then passed to the server. The server tells the verification simulator what noise is needed.

To ensure probabilities are small, a scaling value is applied.
```julia
# Prob scaling
p_scale = 0.05
```

The following examples show how easy it is to insert a pre-made noise model. 

###### Damping 

```julia
# Damping
p = [p_scale*rand() for i in vertices(para[:graph])]
model = Damping(Quest(),SingleQubit(),p)
server = NoisyServer(model)
vbqc_outcome = run_verification_simulator(server,Verbose(),para)
```  

###### Dephasing 

```julia
# Dephasing
p = [p_scale*rand() for i in vertices(para[:graph])]
model = Dephasing(Quest(),SingleQubit(),p)
server = NoisyServer(model)
vbqc_outcome = run_verification_simulator(server,Verbose(),para)
```

###### Depolarising 

```julia
# Depolarising
p = [p_scale*rand() for i in vertices(para[:graph])]
model = Depolarising(Quest(),SingleQubit(),p)
server = NoisyServer(model)
vbqc_outcome = run_verification_simulator(server,Verbose(),para)
```

###### Pauli

```julia
# Pauli
p_xyz(p_scale) = p_scale .* [rand(),rand(),rand()]
p = [p_xyz(p_scale) for i in vertices(para[:graph])]
model = Pauli(Quest(),SingleQubit(),p)
server = NoisyServer(model)
vbqc_outcome = run_verification_simulator(server,Verbose(),para)
```

###### Vector of models

```julia
    # Vector of noise models
model_vec = [Damping,Dephasing,Depolarising,Pauli]
p_damp = [p_scale*rand() for i in vertices(para[:graph])]
p_deph = [p_scale*rand() for i in vertices(para[:graph])]
p_depo = [p_scale*rand() for i in vertices(para[:graph])]
p_pauli = [p_xyz(p_scale) for i in vertices(para[:graph])]
prob_vec = [p_damp,p_deph,p_depo,p_pauli]

models = Vector{NoiseModels}()
for m in eachindex(model_vec)
    push!(models,model_vec[m](Quest(),SingleQubit(),prob_vec[m]))
end
server = NoisyServer(models)
vbqc_outcome = run_verification_simulator(server,Verbose(),para)
```

###### Kraus map

**This functionality needs to be tested, and a warning will display the untested quality.**

This snippet is an example of how the user will call a single qubit Kraus model. 

```julia
# Krau
p = # some Kraus operators
model = Kraus(Quest(),SingleQubit(),p)
server = NoisyServer(model)
vbqc_outcome = run_verification_simulator(server,Verbose(),para)
```