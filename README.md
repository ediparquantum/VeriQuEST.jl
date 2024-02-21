# VeriQuEST.jl

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://fieldofnodes.github.io/VeriQuEST.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://fieldofnodes.github.io/VeriQuEST.jl/dev/)
[![Build Status](https://github.com/fieldofnodes/VeriQuEST.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/fieldofnodes/VeriQuEST.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Build Status](https://travis-ci.com/fieldofnodes/VeriQuEST.jl.svg?branch=main)](https://travis-ci.com/fieldofnodes/VeriQuEST.jl)
[![Coverage](https://codecov.io/gh/fieldofnodes/VeriQuEST.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/fieldofnodes/VeriQuEST.jl)


# Quantum emulation

Quantum computation is an exciting field. There are many research institutes and companies working hard to push the state of the art into the era beyond the noisy intermediate-scale quantum (NISQ) era. This package is designed to emulate quantum computation classically. Specifically, `VeriQuEST.jl` is an emulator of measurement based quantum computation (MBQC). Different to the gate model, MBQC relies on entangled states, projective measurements and adaptivity to perform quantum computation.


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


