# Gorver search MBQC

Run the following script. The search options can be `00`, `01`, `10` and `11`. The results will be the search.

```julia
using VeriQuEST


state_type = DensityMatrix()
total_rounds,computation_rounds = 100,50

# Grover graph
num_vertices = 8
graph = Graph(num_vertices)
add_edge!(graph,1,2)
add_edge!(graph,2,3)
add_edge!(graph,3,6)
add_edge!(graph,6,7)
add_edge!(graph,1,4)
add_edge!(graph,4,5)
add_edge!(graph,5,8)
add_edge!(graph,7,8)



input = (indices = (),values = ())
output = (7,8)


# Julia is indexed 1, hence a vertex with 0 index is flag for no flow
function forward_flow(vertex)
    v_str = string(vertex)
    forward = Dict(
        "1" =>4,
        "2" =>3,
        "3" =>6,
        "4" =>5,
        "5" =>8,
        "6" =>7,
        "7" =>0,
        "8" =>0)
    forward[v_str]
end


function generate_grover_secret_angles(search::String)

    Dict("00"=>(1.0*π,1.0*π),"01"=>(1.0*π,0),"10"=>(0,1.0*π),"11"=>(0,0)) |>
    x -> x[search] |>
    x -> [0,0,1.0*x[1],1.0*x[2],0,0,1.0*π,1.0*π] |>
    x -> Float64.(x)
end

search = "11"
secret_angles = generate_grover_secret_angles(search)



para= (
    graph=graph,
    forward_flow = forward_flow,
    input = input,
    output = output,
    secret_angles=secret_angles,
    state_type = state_type,
    total_rounds = total_rounds,
    computation_rounds = computation_rounds)
```
To run MBQC, UBQC and VBQC

```julia
mbqc_outcome = run_mbqc(para)
ubqc_outcome = run_ubqc(para)
vbqc_outcome = run_verification_simulator(TrustworthyServer(),Verbose(),para)
```

## Noisy models in verification

Set a scaling factor to ensure noise is not randomly chosen above threshold.

```julia
p_scale = 0.1
```

### Damping noise
```julia
# Damping
p = [p_scale*rand() for i in vertices(para[:graph])]
model = Damping(SingleQubit(),p)
server = NoisyChannel(model)
vbqc_outcome = run_verification_simulator(server,Verbose(),para)
```  

### Dephasing noise
```julia
# Dephasing
p = [p_scale*rand() for i in vertices(para[:graph])]
model = Dephasing(SingleQubit(),p)
server = NoisyChannel(model)
vbqc_outcome = run_verification_simulator(server,Verbose(),para)
```

### Depolarising noise
```julia
# Depolarising
p = [p_scale*rand() for i in vertices(para[:graph])]
model = Depolarising(SingleQubit(),p)
server = NoisyChannel(model)
vbqc_outcome = run_verification_simulator(server,Verbose(),para)
```

### Pauli noise
```julia
# Pauli
p_xyz(p_scale) = p_scale .* [rand(),rand(),rand()]
p = [p_xyz(p_scale) for i in vertices(para[:graph])]
model = Pauli(SingleQubit(),p)
server = NoisyChannel(model)
vbqc_outcome = run_verification_simulator(server,Verbose(),para)
```

### Vector of noise models

```julia
# Vector of noise models
model_vec = [Damping,Dephasing,Depolarising,Pauli]
p_damp = [p_scale*rand() for i in vertices(para[:graph])]
p_deph = [p_scale*rand() for i in vertices(para[:graph])]
p_depo = [p_scale*rand() for i in vertices(para[:graph])]
p_pauli = [p_xyz(p_scale) for i in vertices(para[:graph])]
prob_vec = [p_damp,p_deph,p_depo,p_pauli]

models = Vector{AbstractNoiseModels}()
for m in eachindex(model_vec)
    push!(models,model_vec[m](SingleQubit(),prob_vec[m]))
end
server = NoisyChannel(models)
vbqc_outcome = run_verification_simulator(server,Verbose(),para)
```
