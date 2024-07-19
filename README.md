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

# Set up input values
graph = Graph(2)
add_edge!(graph,1,2)


io = InputOutput(Inputs(),Outputs(2))
qgraph = QuantumGraph(graph,io)
function forward_flow(vertex)
    v_str = string(vertex)
    forward = Dict(
        "1" =>2,
        "2"=>0)
    forward[v_str]
end
flow = Flow(forward_flow)
measurement_angles = Angles([π/2,π/2])
total_rounds = 10
computation_rounds = 1
trapification_strategy = TestRoundTrapAndDummycolouring()



# Initial setups
ct = LeichtleVerification(
    total_rounds,
    computation_rounds,
    trapification_strategy,
    qgraph,flow,measurement_angles)
nt_bp = BellPairExplicitNetwork()
nt_im = ImplicitNetworkEmulation()
st = DensityMatrix()
ch = NoisyChannel(NoNoise(NoQubits()))

for i in Base.OneTo(100)
    ver_res1 = run_verification_simulator(ct,nt_bp,st,ch)
    ver_res2 = run_verification_simulator(ct,nt_im,st,ch)
    @assert ver_res1.tests isa Ok
    @assert ver_res2.tests isa Ok
end

vr = run_verification_simulator(ct,nt_bp,st,ch)
get_tests(vr) 
get_computations(vr)
get_tests_verbose(vr)
get_computations_verbose(vr) 
get_computations_mode(vr) 
```

This script can be seen as the mandatory configuration used to run all subsequent computations.


