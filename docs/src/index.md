# Introduction to VeriQuEST.jl

VeriQuEST.jl is a Julia package emulating a special subset of quantum computation called verification. This is the process of determining if a quantum computation split between at least two parties, traditionaly an "Alice" and "Bob" client-server model, can be secure. Alice, the client, uses Bob, the server, to complete quantum compuation she can not. Alice does not want Bob to know anything private about her computation. She also wants assurannces that Bob is not malicious nor too noisy. If Bob is either, than Alice wants to know this is the case, then she can choose how to proceed, typically aborting the job.

Verification relies, among other things, on universal blind quantum computing (UBQC), a subset of the measurement-based quantum computing (MBQC) paradigm. This paradigm, unlike the common "gate-based" model, relies on entanglement, mid-circuit measurement and interactive solving to compute. MBQC and UBQC compute algorirthms that are easily represented by a graph of vertices and edges. Each vertex represents a qubit and each edge is an entangling gate. Qubits are measured during the algorithm's execution (e.g., mid-circuit measurement), with outcomes informing measurement basis for future measurements. Security is gauranteed through blindness, the act of hiding specific qubit states by the client from the server. By repeating the same graph multiple times, with the caveat that a secret proportion of repetitions are actually tests to gauge the server, vertification can be ensured. This method is even robust to constant noise by increasing the number of repetitions. Analysis of the repetitions as a whole will yield the trustworthyness, maliciousness and noisyness of Bob.

Quantum operations are emulated with the QuEST library [QuEST's GitHub](https://github.com/QuEST-Kit/QuEST). QuEST is a C library capable of emulating quantum computation classically, agnostic of most hardware. VeriQuEST uses [QuEST.jl](https://github.com/fieldofnodes/QuEST.jl) to access the C library through [QuEST_jll.jl](https://github.com/JuliaBinaryWrappers/QuEST_jll.jl) a binary generated with [BinaryBuilder.jl](https://github.com/JuliaPackaging/BinaryBuilder.jl).

## Package features

Features present in the VerifQuEST package:

* Can run standard MBQC algorithms
* Can run UBQC
* Verification emulation in specific conditions:
  * Ideal pure states
  * Mixed noiseless states
  * Uncorrelated noise
  * Single qubit pre-entanglement noise
  * (in development) multiple qubit noise models
  * (in development) hardware specific realistic noise models 
* Noise models include: damping, dephasing, depolarising, Pauli, density matrix mixing and Kraus maps

## Quick start

VeriQuEST is on the general registry.

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

