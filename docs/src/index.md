
```@docs
    InputQubits
```

```@docs
    NoInputQubits
```

```@docs
    ClusterState
```

```@docs
    MBQCInput
```

```@docs
    MBQCOutput
```

```@docs
    MBQCGraph
```

```@docs
    MBQCFlow
```

```@docs
    MBQCAngles
```

```@docs
    MBQCResourceState
```

```@docs
    MBQCMeasurementOutcomes
```



```@docs
    c_shift_index(n)
```

```@docs
    c_iterator(N)
```


```@docs
    init_plus_phase_state!(::Phase,qureg,qᵢ,φᵢ)
```

```@docs
    init_plus_phase_state!(::NoPhase,qureg,qᵢ)
```

```@docs
    generate_random_greedy_color(g,reps)
```

```@docs
    separate_each_color(g::Graphs.Coloring{Int64})
```

```@docs
    get_random_coloring(c::Vector{Vector{Int64}})
```

```@docs
    set_vertex_type!(::Client,resource,mg)
```

```@docs
    set_io_qubits_type!(::MBQC,resource,mg)
```

```@docs
    set_io_qubits_type!(::ComputationRound,resource,mg)
```

```@docs
    set_io_qubits_type!(::TestRound,resource,mg)
```

```@docs
    init_qubit(::TrapQubit)::Float64
```

```@docs
    init_qubit(::DummyQubit)::Int64
```

```@docs
draw_bit()::Int64
```

```@docs
rand_k_0_7()::Float64
```

```@docs
draw_θᵥ()::Float64
```

```@docs
draw_rᵥ()::Int64
```

```@docs
draw_dᵥ()::Int64
``` 

```@docs
    get_number_vertices(resource::MBQCResourceState)
```

```@docs
    get_edge_iterator(resource::MBQCResourceState)
```

```@docs
    get_vertex_iterator(resource::MBQCResourceState)
```

```@docs
    get_vertex_neighbours(resource::MBQCResourceState, vertex)
```

```@docs
    compute_angle_δᵥ(::TestRound,::DummyQubit,θᵥ)
```

```@docs
    compute_angle_δᵥ(::TestRound,::TrapQubit,θᵥ,rᵥ)
```

```@docs
    compute_angle_δᵥ(::ComputationRound,::InputQubits,ϕ,Sx,Sz,θᵥ,rᵥ,xᵥ)
```

```@docs
    compute_angle_δᵥ(::ComputationRound,::NoInputQubits,ϕ,Sx,Sz,θᵥ,rᵥ)
```

```@docs
    compute_angle_δᵥ(::MBQC,::Union{NoInputQubits,InputQubits},ϕ,Sx,Sz)
```

