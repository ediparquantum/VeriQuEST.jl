# VeriQuEST.jl

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://fieldofnodes.github.io/VeriQuEST.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://fieldofnodes.github.io/VeriQuEST.jl/dev/)
[![Build Status](https://github.com/fieldofnodes/VeriQuEST.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/fieldofnodes/VeriQuEST.jl/actions/workflows/CI.yml?query=branch%3Amain)



## Introduction

`VeriQuEST.jl` is a measurement based quantum computing package. To complete the quatnum emulation, the C library [QuEST](https://github.com/QuEST-Kit/QuEST), is used. VeriQuEST's purpose is to emulate noisy verification protocols.


## Quick start
Run the following commands along with relevant input to implement the blind verification.

```julia
using Pkg
Pkg.add("VeriQuEST")
```

or

```julia
] add VeriQuEST
```

Then, 

```julia
using VeriQuEST
```

A generic template, currently these variable names are mandatory.

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

This script can be seen as the mandatory configuration used to run all subsequent computations.


