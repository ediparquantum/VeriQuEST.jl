# RobustBlindVerification.jl

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://fieldofnodes.github.io/QuESTMbqcBqpVerification.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://fieldofnodes.github.io/QuESTMbqcBqpVerification.jl/dev/)
[![Build Status](https://github.com/fieldofnodes/QuESTMbqcBqpVerification.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/fieldofnodes/QuESTMbqcBqpVerification.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Build Status](https://travis-ci.com/fieldofnodes/QuESTMbqcBqpVerification.jl.svg?branch=main)](https://travis-ci.com/fieldofnodes/QuESTMbqcBqpVerification.jl)
[![Coverage](https://codecov.io/gh/fieldofnodes/QuESTMbqcBqpVerification.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/fieldofnodes/QuESTMbqcBqpVerification.jl)


Implementation of protocol 1 from Leichtle et al ([Verifying BQP Computations on Noisy Devices with Minimal Overhead](https://journals.aps.org/prxquantum/abstract/10.1103/PRXQuantum.2.040302)).


## Example
Run the following to implement

Load packages, if not installed, then run `] add <PackageName>`, for `QuEST_jl`, go to [https://github.com/fieldofnodes/QuEST_jl](https://github.com/fieldofnodes/QuEST_jl) for installation instructions.
```julia
using Pkg
Pkg.activate(".")

using QuEST_jl
import QuEST_jl.QuEST64
QuEST = QuEST_jl.QuEST64
qreal = QuEST.QuEST_Types.qreal
using Test
using StatsBase
using Graphs
using CairoMakie
using RobustBlindVerification
```
Define the quantum state type, either a state vector backend (`StateVector()`) or a density matrix backend (`DensityMatrix()`)

```julia
  state_type = DensityMatrix()
```
Using the Julia Graphs package, implement a graph.

```julia
  num_vertices = N
  graph = Graph(num_vertices)
```

Define the flow. As long a qubit index is inputted and a qubit index is ouputed, any function will do. Note that Julia is indexed starting from $1$, but QuEST (the quantum simulator) is in C and indexed from $0$. 

The `forward_flow` function takes a present qubit and returns the next qubit according to the flow.
```julia
function forward_flow(vertex)
    # Define function or data structure to output new vertex index
    return forward_vertex
end
```
The `backward_flow` package takes the current vertex and returns the previous vertex.

```julia
function backward_flow(vertex)
  # Define function or data structure to output old vertex index
  return backward_vertex
end
```

Define the input and output vertices as tuples. For input vertices, provide the indices and the classical inputs. For no inputs, provide empty brackets `()`

```julia
  input_indices = () # a tuple of indices 
  input_values = () # a tuple of input values
```

Provide the vertices considered the outputs of the graph.

```julia
  output_indices = (output_index_1,output_index_2,...,output_index_M)
```

for $M$ output vertices.

Provide the angles known to the client only. Data structures encapsulated by `[]` are vectors in Julia.

```julia
  secret_angles = []
```

Define the total number of rounds, the number of computational rounds and the test round threshold value (e.g. $n$, $d$, abd $w$ in Leichtle et al). The number of test rounds is $t = n - d$.
```julia
  total_rounds,computation_rounds = n,d
  test_rounds_theshold = w
```

Contain all separate variables and parametes into the following `NamedTuple`. Do not change this, simply name all of the above variables as seen in the code snippets. 

```julia
para= (
    graph=graph,
    forward_flow = forward_flow,
    backward_flow=backward_flow,
    input_indices = input_indices,
    input_values = input_values,
    output_indices =output_indices,
    secret_angles=secret_angles,
    state_type = state_type,
    total_rounds = total_rounds,
    computation_rounds = computation_rounds,
    test_rounds_theshold = test_rounds_theshold)
```

To just run the verification simulator

```julia
run_verification_simulator(para)
```

The outcome will be a named tuple

```julia
(test_verification = test_verification_outcome, computation_verification = computation_verification_outcome, mode_outcome = mode_outcome)
```

where `test_verification_outcome`and `computation_verification_outcome` is of type `Ok()` or `Abort()` based on outcomes computed according to Leichtle et al. The outcome of the computation is `mode_outcome`.


For an example see `grover_verification_script.jl`.


