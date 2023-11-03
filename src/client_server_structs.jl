struct Client end
struct Struct end
struct Phase end
struct NoPhase end
struct QubitInitialState end
struct BasisAngle end
struct MeasurementOutcome end
struct AdjacencyList end
struct Server end
struct DummyQubit end
struct ComputationQubit end
struct TrapQubit end
struct ComputationRound end
struct TestRound end
struct SecretAngles end
struct Ok end
struct Abort end
struct TrapPass end
struct TrapFail end  

"""
    InputQubits

    A struct representing input qubits in the MBQC framework.

    # Description
    `InputQubits` is a marker struct used to indicate the presence of input qubits in an MBQC computation. It is typically used in combination with other data structures or algorithms to handle input qubits in the computation.

    # Example
    ```julia
    # Declare input qubits
    input_qubits = InputQubits()
    ```

"""
struct InputQubits end

"""
    NoInputQubits

    A struct representing the absence of input qubits in the MBQC framework.

    # Description
    `NoInputQubits` is a marker struct used to indicate the absence of input qubits in an MBQC computation. It can be used as a flag or placeholder to handle scenarios where there are no input qubits in the computation.

    # Example
    ```julia
    # Declare absence of input qubits
    no_input_qubits = NoInputQubits()
    ```

"""
struct NoInputQubits end


"""
    ClusterState

    A struct representing the cluster state in the MBQC framework.

    # Description
    `ClusterState` is a marker struct used to represent the cluster state in an MBQC computation. It can be used in combination with other data structures or algorithms specific to the cluster state model.

    # Example
    ```julia
    # Declare cluster state
    cluster_state = ClusterState()
    ```

"""
struct ClusterState end





"""
    MBQCInput(indices,values)

    - Struct representing an input set into the graph, can be empty

    # Parameters
    - `indices`: has type Tuple on normally integers (whole numbers 1 to N) and correspond to vertices in a graph.
    - `values`: has type Tuple, can be any type

    # Example
    ```
    julia> indices = (1,2,3,4)
    julia> values = (0,1,1,0) #Computational basis outcomes
    julia> mbqc_input = MBQCInput(indices,values)
    ```
"""
struct MBQCInput 
    indices
    values
end

"""
    MBQCOutput(indices)

    - Struct representing an output set into the graph, can be empty.

    # Parameters
    - `indices`: has type Tuple on normally integers (whole numbers 1 to N) and correspond to the vertices in a graph.


    # Example
    ```
    julia> indices = (10,11,12)
    julia> mbqc_output = MBQCOutput(indices)
    ```
"""
struct MBQCOutput 
    indices
end


struct MBQCColouringSet
    computation_round
    test_round
end

"""
    MBQCGraph(graph,input,output)

    - Struct representing the graph used in the MBQC. Container holds the graph as well as the input and output sets.

    # Parameters
    - `graph`: Any graph suitable for MBQC
    - `input`: has type MBQCInput
    - `output`: had type MBQCOutput

    # Example
    ```
    julia> using Graphs # use using Pkg; Pkg.add("Graphs") is not installede
    julia> graph = Graphs.grid([1,4]) # 1D cluster graph (path graph) on 4 vertices
    julia> indices,values = (1),(0)
    julia> input  = MBQCInput(indices,values)
    julia> indices = (4)
    julia> output  = MBQCOutput(indices)
    julia> mbqc_graph = MBQCGraph(graph,input,output)
    ```
"""
struct MBQCGraph
    graph
    colouring::MBQCColouringSet
    input::MBQCInput
    output::MBQCOutput
end

"""
    MBQCFlow(forward_flow, backward_flow)

    Struct representing flow in MBQC.

    # Definition of Flow
    - `forward_flow`, `f`: Oᶜ → Iᶜ is a mapping `v ↦ f(v)` with an inverse `f⁻¹(v) ↦ v`, with partial order "≤". The partial order is said to map the present to the future or the present to the past.
    - (a) `v ∼ f(v)`, where "∼" defines the neighbourhood `N(f(v))` and `v` has set membership.
    - (b) `v ≤ f(v)`
    - (c) `w ∼ f(v)`, then ∀ `v`, `v ≤ w`

    ## Example
    - One dimensional lattice, the "path graph", where a vertex is represented as "()" and an edge is represented as "---".
    - Let `i` be the index of each vertex so that `i = {1, 2, 3, 4}` and
    - `p := (1)---(2)---(3)---(4)`
    - `f(i) := i + 1`
    - `f⁻¹(i) := i - 1`
    - `f([1, 2, 3]) = [2, 3, 4]`, since 4 has no future, there is no 4 + 1 answer.
    - `f⁻¹([2, 3, 4]) = [1, 2, 3]`, since 1 has no past, there is no 1 - 1 answer.

    # Parameters
    - `forward_flow`: A mapping to take an input vertex and return the output vertex such that the definitions of flow hold. The forward flow function can be any container that takes a vertex index as input and outputs a new vertex index.
    - `backward_flow`: A mapping to take an output vertex and return the input vertex. The backward flow function maps the inverse of the forward flow.

    # Example
    ```julia
    # Define forward and backward flow functions
    forward_flow(io) = io[2]
    backward_flow(io) = io[1]

    # Create an MBQCFlow
    mbqc_flow = MBQCFlow(forward_flow, backward_flow)
    ```
"""
struct MBQCFlow 
    forward_flow
    backward_flow
end

struct ForwardFlow end
struct BackwardFlow end


"""
    MBQCAngles(angles) 

    - Struct representing the angles associated to the graph. The number of angles will be the same as the vertices in the graph.

    # Parameters
    - `angles`: A listed set of values, as long as the angles are indexable in the same ways that the vertices are.

    # Example
    ```
    julia> angles = [π,π/4,5π/4,7π/4]
    julia> mbqc_angles = MBQCAngles(angles) 
    ```
"""
struct MBQCAngles 
    secret_angles
    public_angles
end

"""
    MBQCResourceState(graph, flow, angles)

    Struct representing a resource state in MBQC.

    # Parameters
    - `graph`: An instance of `MBQCGraph` representing the underlying graph structure.
    - `flow`: An instance of `MBQCFlow` representing the flow in the resource state.
    - `angles`: An instance of `MBQCAngles` representing the angles associated with each vertex.

    ## Example
    ```julia
    # Create an MBQCGraph
    graph = MBQCGraph([1, 2, 3], [(1, 2), (2, 3)])

    # Create an MBQCFlow
    flow = MBQCFlow((1, 2) => 2, (2, 3) => 3)

    # Create an MBQCAngles
    angles = MBQCAngles([π/2, π/4, π/3])

    # Create an MBQCResourceState
    resource_state = MBQCResourceState(graph, flow, angles)
    ```
"""
struct MBQCResourceState 
    graph::MBQCGraph
    flow::MBQCFlow
    angles::MBQCAngles
end



"""
    MBQCMeasurementOutcomes(outcomes)

    Struct representing measurement outcomes in MBQC.

    # Parameter
    - `outcomes`: An array or container representing the measurement outcomes.

    ## Example
    ```julia
    # Define measurement outcomes
    outcomes = [0, 1, 1, 0]

    # Create an MBQCMeasurementOutcomes
    measurement_outcomes = MBQCMeasurementOutcomes(outcomes)
    ```
"""
struct MBQCMeasurementOutcomes 
    outcomes
end


struct StateVector end
struct DensityMatrix end

struct DummyQubitZeroOneInitialisationError end
struct QubitFloatPhaseInitialisationError end
struct FunctionNotMeantToBeUsed end

