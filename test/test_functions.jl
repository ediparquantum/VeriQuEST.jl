function test_struct_creation()
    indices = ()
    values = ()
    computation_round,test_round = (),()
    graph = ()
    f_flow = ()
    b_flow = ()
    outcomes = ()
    angles = ()
    IQ = InputQubits()
    NIQ = NoInputQubits()
    COL = MBQCColouringSet(computation_round,test_round)
    CS = ClusterState()
    MI = MBQCInput(indices,values)
    MO = MBQCOutput(indices)
    MG = MBQCGraph(graph,COL,MI,MO)
    MF = MBQCFlow(f_flow,b_flow)
    FF = ForwardFlow()
    BF = BackwardFlow()
    MA = MBQCAngles(angles)
    MR = MBQCResourceState(MG,MF,MA)
    MMO = MBQCMeasurementOutcomes(outcomes)
    C = Client()
    S = Struct()
    P = Phase()
    NO = NoPhase()
    QIS= QubitInitialState()
    BA = BasisAngle()
    MOC = MeasurementOutcome()
    AL = AdjacencyList()
    SR = Server()

    @test IQ isa InputQubits
    @test NIQ isa NoInputQubits
    @test CS isa ClusterState
    @test MI isa MBQCInput
    @test MO isa MBQCOutput
    @test COL isa MBQCColouringSet
    @test MG isa MBQCGraph
    @test MF isa MBQCFlow
    @test FF isa ForwardFlow
    @test BF isa BackwardFlow
    @test MA isa MBQCAngles
    @test MR isa MBQCResourceState
    @test MMO isa MBQCMeasurementOutcomes
    @test C isa Client
    @test S isa Struct
    @test P isa Phase
    @test NO isa NoPhase
    @test QIS isa QubitInitialState
    @test BA isa BasisAngle
    @test MOC isa MeasurementOutcome
    @test AL isa AdjacencyList
    @test SR isa Server

    @test MR.angles isa MBQCAngles
    @test MR.angles.angles isa Tuple
    @test MR.flow isa MBQCFlow
    @test MR.graph isa MBQCGraph
    
end

function test_c_shift()
    num_tests = 1_000
    for i in Base.OneTo(num_tests)
        julia_index = rand(1:1<<10)
        c_index = c_shift_index(julia_index)
        @test c_index == julia_index-1
    end
end

function test_c_iterator()
    num_tests = 1_000
    for i in Base.OneTo(num_tests)
        N = rand(1:1<<10)
        iterator = c_iterator(N)
        max_iter = collect(iterator) |> maximum
        min_iter = collect(iterator) |> minimum
        @test min_iter == 0
        @test max_iter == c_shift_index(N)
        @test iterator isa Base.Iterators.TakeWhile{Base.Iterators.Count{Int64, Int64}, Base.Fix2{typeof(<), Int64}}
    end
end

function test_env()
    env1 = QuEST.createQuESTEnv()
    env2 = QuEST.createQuESTEnv()
    QuEST.destroyQuESTEnv(env1)
    QuEST.destroyQuESTEnv(env2)
end

function test_qureg()
    env= QuEST.createQuESTEnv()
    for i=1:10
    qureg1 = QuEST.createQureg(i, env)
    qureg2 = QuEST.createQureg(i, env)    
    @test qureg1.numQubitsRepresented == i
    @test qureg2.numQubitsRepresented == i
    QuEST.destroyQureg(qureg1, env) 
    QuEST.destroyQureg(qureg2, env)
    end
    QuEST.destroyQuESTEnv(env)

end

function test_qureg_density()
    env= QuEST.createQuESTEnv()
    for i=1:10
    qureg1 = QuEST.createDensityQureg(i, env)
    qureg2 = QuEST.createDensityQureg(i, env)    
    @test qureg1.numQubitsRepresented == i
    @test qureg2.numQubitsRepresented == i
    QuEST.destroyQureg(qureg1, env) 
    QuEST.destroyQureg(qureg2, env)
    end
    QuEST.destroyQuESTEnv(env)

end

function test_plusState(tolerance)
    num_tests = 1_000
    env= QuEST.createQuESTEnv()
    for i in Base.OneTo(num_tests)
        num_qubits = 1
        qureg = QuEST.createQureg(num_qubits, env)
        q_ind = c_shift_index(1)
        QuEST.hadamard(qureg,q_ind)
        @test QuEST.getProbAmp(qureg, q_ind) ≈ 0.5 atol = tolerance
        QuEST.destroyQureg(qureg, env) 
    end
    for i in Base.OneTo(num_tests)
        num_qubits = 1
        qureg = QuEST.createDensityQureg(num_qubits, env)
        q_ind = c_shift_index(1)
        QuEST.hadamard(qureg,q_ind)
        for i=c_iterator(2^num_qubits)
            for j=c_iterator(2^num_qubits)
                dens_amps = QuEST.getDensityAmp(qureg, i, j)
                @test abs(dens_amps)^2 ≈ 0.25 atol = tolerance
            end
        end
    
        QuEST.destroyQureg(qureg, env) 
    end
    QuEST.destroyQuESTEnv(env)
end

function check_createCloneQureg()
    num_tests = 10
    env= QuEST.createQuESTEnv()
    for i =1:num_tests
        num_qubits = rand(2:12)
        qureg1 = QuEST.createQureg(num_qubits, env)
        for qubit =0:num_qubits-1
            QuEST.rotateX(qureg1, qubit, rand(qreal))
        end
        for qubit = 0:num_qubits-2
            QuEST.controlledNot(qureg1, qubit, qubit+1)
        end
        qureg2 = QuEST.createCloneQureg(qureg1, env)
        @test qureg1.numQubitsRepresented == qureg2.numQubitsRepresented
        @test qureg1.numAmpsTotal == qureg2.numAmpsTotal
        @test QuEST.getNumAmps(qureg1) == QuEST.getNumAmps(qureg2)
        @test QuEST.getNumQubits(qureg1) == QuEST.getNumQubits(qureg2)
        for ind=1:2^num_qubits-1
            @test QuEST.getProbAmp(qureg1, ind) == QuEST.getProbAmp(qureg2, ind)
            @test QuEST.getRealAmp(qureg1, ind) == QuEST.getRealAmp(qureg2, ind)
            @test QuEST.getImagAmp(qureg1, ind) == QuEST.getImagAmp(qureg2, ind)
        end 
    end
    QuEST.destroyQuESTEnv(env)
end

function test_phase_θ(tolerance)
    # Test 0 phase is the identity
    θ = 0
    m = phase(θ)
    @test m == I(2)

    # Pi
    θ = π
    m = phase(θ)
    eiθ = cos(θ) + im*sin(θ)
    phase_m_flip = Complex.([1 0;0 1])*Complex.([1 0;0 eiθ])
    @test m ≈ phase_m_flip atol=tolerance

end

function test_basic_call_measurement()
    get_δ() = 2*π*rand()
    get_measurement_outcome() = rand([0,1])
    update_client_graph!(angle,measurement) = (angle,measurement)

    δ = get_δ()
    m = get_measurement_outcome()
    angle_measurement = update_client_graph!(δ,m)
    @test angle_measurement == (δ,m)

    N = 1e5 |> Int
    for i in Base.OneTo(N)
        δ = get_δ()
        m = get_measurement_outcome()
        angle_measurement = update_client_graph!(δ,m)
        @test angle_measurement == (δ,m)
    end
end

function test_create_complex_identity()
    @test ident_2x2() == I(2)
end

function test_qubit_initialisation(::Client,::DensityMatrix,::DummyQubit,::NoInputQubits)
    qubit_input_value=[0,1]
    for test in qubit_input_value
        num_qubits = 1
        quantum_env = create_quantum_env(Client())
        quantum_state = create_quantum_state(Client(),DensityMatrix(),quantum_env,num_qubits)
        qubit_index = 1
        initialise_qubit(DummyQubit(),NoInputQubits(),quantum_state,qubit_index,test)
        amps = [QuEST.getDensityAmp(quantum_state, i, j) for i in [0,1], j in [0,1]]
        QuEST.destroyQureg(quantum_state, quantum_env)

        ## Test that the qubit is in the 1 state
        @test amps[test+1,test+1] == 1.0+0.0im
    end
end

function test_qubit_initialisation(::Client,::DensityMatrix,vertex_type::Union{TrapQubit,ComputationQubit},vertex_io_type::Union{InputQubits,NoInputQubits},tolerance)
    qubit_input_value=draw_θᵥ()
    num_qubits = 1
    quantum_env = create_quantum_env(Client())
    quantum_state = create_quantum_state(Client(),DensityMatrix(),quantum_env,num_qubits)
    qubit_index = 1
    initialise_qubit(vertex_type,vertex_io_type,quantum_state,qubit_index,qubit_input_value)
    amps = [QuEST.getDensityAmp(quantum_state, i, j) for i in [0,1], j in [0,1]]
    QuEST.destroyQureg(quantum_state, quantum_env)

    ## Test that the qubit is in the 1 state
    # Test results
    H = (1/sqrt(2))*[1 1;1 -1]
    Ph = phase(qubit_input_value)
    PH = Ph*H
    ρ = [1 0;0 0]
    ρ̂ = PH*ρ*PH'

    @test amps ≈ ρ̂ atol = tolerance

end

function test_get_state_vector_pair_per_qubit()
    @test get_state_vector_pair_per_qubit(1) == (1,2)
    @test get_state_vector_pair_per_qubit(2) == (3,4)
end

function test_get_density_matrix_indices_per_qubits()
    qubit1,qubit2=1,1
    q₁₂ = get_density_matrix_indices_per_qubits(qubit1,qubit2)
    mat = [(1,1) (1,2);(2,1) (2,2)]
    @test q₁₂ == mat
end

function test_get_amps_0_1_states_1_qubit(::Client,::DensityMatrix)
    # Single qubit density matrix
    # Test init in the blank state
    quantum_env = create_quantum_env(Client())
    num_qubits = 1
    quantum_state = create_quantum_state(Client(),DensityMatrix(),quantum_env,num_qubits)
    quest_amps = get_all_amps(DensityMatrix(),quantum_state)[1]
    true_amps = Complex.(Float64.([1 0;0 0]))
    @test quest_amps == true_amps
    QuEST.destroyQureg(quantum_state,quantum_env)

    # Single qubit density matrix
    # Test init in the blank state
    num_qubits = 1
    quantum_state = create_quantum_state(Client(),DensityMatrix(),quantum_env,num_qubits)
    QuEST.pauliX(quantum_state,0)
    quest_amps = get_all_amps(DensityMatrix(),quantum_state)[1]
    true_amps = Complex.(Float64.([0 0;0 1]))
    @test quest_amps == true_amps
    QuEST.destroyQureg(quantum_state,quantum_env)
    QuEST.destroyQuESTEnv(quantum_env)
end

function test_get_amps_plus_phase_states_1_qubit(::Client,::DensityMatrix,tolerance)
    quantum_env = create_quantum_env(Client())
    # Single qubit density matrix
    # Test plus state amps, no phase
    num_qubits = 1
    quantum_state1 = create_quantum_state(Client(),DensityMatrix(),quantum_env,num_qubits)
    quantum_state2 = create_quantum_state(Client(),DensityMatrix(),quantum_env,num_qubits)
    quantum_state3 = create_quantum_state(Client(),DensityMatrix(),quantum_env,num_qubits)
    init_plus_phase_state!(NoPhase(),quantum_state1,1)
    init_plus_phase_state!(Phase(),quantum_state2,1,0.0)
    QuEST.initPlusState(quantum_state3)
    quest_amps1 = get_all_amps(DensityMatrix(),quantum_state1)[1]
    quest_amps2 = get_all_amps(DensityMatrix(),quantum_state2)[1]
    quest_amps3 = get_all_amps(DensityMatrix(),quantum_state3)[1]
    true_amps = Complex.(Float64.([1 1;1 1])) |> normalize
    @test quest_amps1 ≈ quest_amps2 atol = tolerance
    @test quest_amps1 ≈ quest_amps3 atol = tolerance
    @test quest_amps1 ≈ true_amps atol = tolerance
    @test quest_amps2 ≈ quest_amps3 atol = tolerance
    @test quest_amps2 ≈ true_amps atol = tolerance
    @test quest_amps3 ≈ true_amps atol = tolerance
    QuEST.destroyQureg(quantum_state1,quantum_env)
    QuEST.destroyQureg(quantum_state2,quantum_env)
    QuEST.destroyQureg(quantum_state3,quantum_env)

    # Single qubit density matrix
    # Test plus state amps, phase
    num_qubits = 1
    quantum_state1 = create_quantum_state(Client(),DensityMatrix(),quantum_env,num_qubits)
    quantum_state2 = create_quantum_state(Client(),DensityMatrix(),quantum_env,num_qubits)
    θ = draw_θᵥ()
    init_plus_phase_state!(Phase(),quantum_state1,1,θ)
    QuEST.hadamard(quantum_state2,0)
    QuEST.phaseShift(quantum_state2,0,θ)
    quest_amps1 = get_all_amps(DensityMatrix(),quantum_state1)[1]
    quest_amps2 = get_all_amps(DensityMatrix(),quantum_state2)[1]
    true_amps = create_plus_phase_density_mat(θ)
    @test quest_amps1 ≈ quest_amps2 atol = tolerance
    @test quest_amps1 ≈ true_amps atol = tolerance
    @test quest_amps2 ≈ true_amps atol = tolerance
    QuEST.destroyQureg(quantum_state1,quantum_env)
    QuEST.destroyQureg(quantum_state2,quantum_env)
    QuEST.destroyQuESTEnv(quantum_env)
end

function test_get_amps_n_qubit(::Client,::DensityMatrix,tolerance)
    quantum_env = create_quantum_env(Client())
    # Double qubit density matrix
    # Test plus 0 state
    num_qubits = 2
    quantum_state = create_quantum_state(Client(),DensityMatrix(),quantum_env,num_qubits)
    QuEST.pauliX(quantum_state,0)
    QuEST.pauliX(quantum_state,1)
    quest_amps1 = get_all_amps(DensityMatrix(),quantum_state)
    num_qubit_per_nm = 4
    amps_mat = [quest_amps1[i][j] for i in Base.OneTo(2^num_qubits),j in Base.OneTo(num_qubit_per_nm)]
    [@test amps_mat[i] == Complex(0.0) for i in 1:15]
    @test amps_mat[16] == Complex(1.0)
    QuEST.destroyQureg(quantum_state,quantum_env)
    QuEST.destroyQuESTEnv(quantum_env)
end


function test_rounds_graphs_in_verification()



    # Create client resource
    is_density=true
    input_indices = [1,2,3]
    input_values = [0,1,1]
    output_indices = 0
    cols,rows = 3,3
    graph = Graphs.grid([cols,rows])
    reps = 100
    computation_colours = ones(nv(graph))
    test_colours = get_vector_graph_colors(graph;reps=reps)
    num_vertices = nv(graph)
    angles = [draw_θᵥ() for i in vertices(graph)]
    forward_flow(vertex) = vertex + rows
    backward_flow(vertex) = vertex - rows
    p = (input_indices = input_indices,input_values = input_values,
        output_indices = output_indices,graph=graph,computation_colours=computation_colours,test_colours=test_colours,
        angles = angles,forward_flow = forward_flow,backward_flow=backward_flow)
    client_resource = create_graph_resource(p)
    state_type = DensityMatrix()
    total_rounds,computation_rounds = 10,5
    round_types = draw_random_rounds(total_rounds,computation_rounds)
    round_graphs = []
    # Iterate over rounds
    for round_type in round_types
        
        # Generate client meta graph
        client_meta_graph = generate_property_graph!(Client(),round_type,client_resource,state_type)
        client_graph = produce_initialised_graph(Client(),client_meta_graph)

       
        for v in vertices(client_meta_graph)
            @test get_prop(client_meta_graph,v,:vertex_io_type) isa Union{NoInputQubits,InputQubits,InputQubits}
            @test get_prop(client_meta_graph,v,:forward_flow) isa Union{Nothing,Int64}
            @test get_prop(client_meta_graph,v,:backward_flow) isa Union{Nothing,Int64}
            @test get_prop(client_meta_graph,v,:X_correction) isa Int64
            @test get_prop(client_meta_graph,v,:Z_correction) isa Union{Vector{Int64},Int64}
            v_type = get_prop(client_meta_graph,v,:vertex_type)
            q_init = get_prop(client_meta_graph,v,:init_qubit)
            @test v_type isa Union{ComputationQubit,TrapQubit,DummyQubit}
            if v_type isa Union{ComputationQubit,TrapQubit}
                @test q_init isa Float64
            elseif v_type isa DummyQubit
                @test q_init isa Int
            end
            @test get_prop(client_meta_graph,v,:outcome) isa DataType

            vertex_io_type = get_prop(client_meta_graph,v,:vertex_io_type)
            if  vertex_io_type isa InputQubits && round_type isa ComputationRound
                @test get_prop(client_meta_graph,v,:classic_input) isa Int64
            end
        end
        # Test the property graph and the client graph match
        @test Graph(client_meta_graph) == client_graph

        client_quantum_state = produce_initialised_qureg(Client(),client_meta_graph)
        server_env = create_quantum_env(Server())
        server_cloned_state = clone_qureq(Server(),client_quantum_state,server_env)
        # Test both quantum states have same and correct type
        q_state_type = QuEST_jl.QuEST64.QuEST_Types.Qureg
        @test client_quantum_state isa q_state_type
        @test server_cloned_state isa q_state_type
        c_amps = get_all_amps(state_type,client_quantum_state)
        s_amps = get_all_amps(state_type,server_cloned_state)

        @test sizeof(c_amps) == sizeof(s_amps)
        @test typeof(c_amps) == typeof(s_amps)

        # Test the quantum state before the server entangles the two
        # are identical
        @test c_amps == s_amps

        # Create server resources
        server_resource = create_resource(Server(),client_graph,client_quantum_state)
        @test client_graph == server_resource["graph"]
        server_quantum_state = server_resource["quantum_state"]

        #=
        20230915 - I do not know how to determine if the amps
        in the density matrices are going to change after
        entanglement occurs. Leaving code block here with date.
        s_e_amps = get_all_amps(state_type,server_quantum_state)
        if round_type isa TestRound
            @info round_type
            @test c_amps == s_e_amps
            @test s_amps == s_e_amps
        else
            @test c_amps != s_e_amps
            @test s_amps != s_e_amps
        end
        =#
        num_qubits_from_server = server_quantum_state.numQubitsRepresented
        @test nv(client_meta_graph) == num_qubits_from_server

        for q in Base.OneTo(num_qubits_from_server)
            ϕ = get_updated_ϕ!(Client(),client_meta_graph,q)
            m = measure_along_ϕ_basis!(Server(),server_quantum_state,q,ϕ)
            @test m isa Int
            store_measurement_outcome!(Client(),client_meta_graph,q,m)
        end
        push!(round_graphs,client_meta_graph)
    end

    # Test that the rounds stored in the graph match those in the 
    # round_types vector
    @test [get_prop(g,:round_type) for g in round_graphs] == round_types
end



function test_is_round_OK()
    trap_results = [1,1,1,1]
    @test is_round_OK(trap_results)
    trap_results = [1,1,1,0]
    @test !is_round_OK(trap_results)
    trap_results = [0,0,0,0]
    @test !is_round_OK(trap_results)
end




# Redo this test according to my notability notes
function test_single_qubit_trap_equals_one_time_pad(num_iterations)
    quantum_env=QuEST.createQuESTEnv()
    test_vec = Base.OneTo(Int(num_iterations))
    # Run test to see that the measurement 
    # outcome always mathches the rᵥ value
    # and call quest directly
    function run_test(quantum_env,rᵥ,θᵥ)
        num_qubits = 1
        q = 0
        ρ = QuEST.createDensityQureg(num_qubits,quantum_env)
        δ = θᵥ + rᵥ*π
        QuEST.hadamard(ρ,q)
        QuEST.phaseShift(ρ,q,θᵥ)
        QuEST.rotateZ(ρ,q,-δ)
        QuEST.hadamard(ρ,q)
        bᵥ = QuEST.measure(ρ, q)
        QuEST.destroyQureg(ρ, quantum_env) 
        @test mod(sum([bᵥ,rᵥ]),2)==0
    end
    
    # Confirm direct computation in `run_test()` returns identical in
    # designed functions
    function run_test_client_server_functions(quantum_env,rᵥ,θᵥ)
        num_qubits = 1
        q=1 # julia function shifts to c 0 index
        quantum_env = create_quantum_env(Client())
        ρ = create_quantum_state(Client(),DensityMatrix(),quantum_env,num_qubits)
        init_plus_phase_state!(Phase(),ρ,q,θᵥ)
        δ = θᵥ + rᵥ*π
        bᵥ = measure_along_ϕ_basis!(Server(),ρ,q,δ)
        QuEST.destroyQureg(ρ, quantum_env) 
        @test mod(sum([bᵥ,rᵥ]),2)==0
    end

    for i in test_vec   
        θᵥ = draw_θᵥ()
        rᵥ = draw_rᵥ()
        run_test(quantum_env,0,θᵥ)
        run_test(quantum_env,1,θᵥ)  
        run_test_client_server_functions(quantum_env,rᵥ,θᵥ)
    end
end
    
    
function test_two_qubit_one_trap_one_dummy(num_iterations)
    # Create the the quantum experience
    quantum_env=QuEST.createQuESTEnv()

    # Function to run the circuit
    function two_qubits_entangled(quantum_env)
        dummy_init = draw_dᵥ()
        one_time_trap_pad = draw_rᵥ()
        trap_angle = draw_θᵥ()
       
      

        # Create the quantum state on 2 qubits
        num_qubits = 2
        ρ = QuEST.createDensityQureg(num_qubits,quantum_env)


        # Initialise qubits
        # qubit 0 trap
        q₀ = 0  
        QuEST.hadamard(ρ,q₀)
        QuEST.phaseShift(ρ,q₀,trap_angle)
        
        
        # qubit 1 dummy
        q₁ = 1
        if dummy_init == 1 
            QuEST.pauliX(ρ,q₁)
        end


        # Entangle the circuits
        QuEST.controlledPhaseFlip(ρ,q₀,q₁)


        # Measure qubit 0 trap
        δ₀ = trap_angle + one_time_trap_pad*π
        QuEST.rotateZ(ρ,q₀,-δ₀)
        QuEST.hadamard(ρ,q₀)
        trap_outcome = QuEST.measure(ρ,q₀)

        # Measure qubit 1 dummy
        δ₁ = draw_θᵥ()
        QuEST.rotateZ(ρ,q₁,-δ₁)
        QuEST.hadamard(ρ,q₁)
        QuEST.measure(ρ,q₁)

        # Destroy register
        QuEST.destroyQureg(ρ, quantum_env) 

        # Return the outcome for the trap
        trap_outcome
        verification_req = mod(sum([trap_outcome,one_time_trap_pad,dummy_init]),2)
        @test verification_req == 0
    end
    
    # Verify circuit
    for i in Base.OneTo(num_iterations)
        two_qubits_entangled(quantum_env)
    end          
end



function test_N_qubit_one_dummy_one_trap_N_dummies(num_iterations,number_dummies)
    # Create the the quantum experience
    quantum_env=QuEST.createQuESTEnv()

    # Function to run the circuit
    function N_qubits_entangled(quantum_env,number_dummies)
        
        # Create the quantum state on 2 qubits
        num_traps = 1
        num_qubits = num_traps + number_dummies
        ρ = QuEST.createDensityQureg(num_qubits,quantum_env)
        
        
        # Trap and dummy draws
        r₀ = draw_rᵥ()
        θ₀ = draw_θᵥ()
        d = [draw_dᵥ() for i in Base.OneTo(number_dummies)]
        dθ = [draw_θᵥ() for i in Base.OneTo(number_dummies)] 
        
        
        # Trap qubit 0
        q₀ = 0
        QuEST.hadamard(ρ,q₀)
        QuEST.phaseShift(ρ,q₀,θ₀)


        # Initialise qubits
        # qubits 1 to N
        for i in Base.OneTo(number_dummies)
            d[i] == 1 ? QuEST.pauliX(ρ,i) : nothing
        end

        
        # Entangle the circuits
        for i in Base.OneTo(number_dummies)
            QuEST.controlledPhaseFlip(ρ,q₀,i)
        end

        
        # Measure qubit 0 trap
        δ₀ = θ₀ + r₀*π
        QuEST.rotateZ(ρ,q₀,-δ₀)
        QuEST.hadamard(ρ,q₀)
        b₀ = QuEST.measure(ρ,q₀)


        # Measure qubit 1 to N dummies
        for i in Base.OneTo(number_dummies)
            QuEST.rotateZ(ρ,i,-dθ[i] )
            QuEST.hadamard(ρ,i)
            QuEST.measure(ρ,i)
        end


        # Destroy register
        QuEST.destroyQureg(ρ, quantum_env) 
        
        # Verify
        verification_values = reduce(vcat,(b₀,r₀,d))
        verification_req = mod(sum(verification_values),2)
        @test verification_req == 0
    end
    
    # Verify circuit
    for i in Base.OneTo(num_iterations)
        N_qubits_entangled(quantum_env,number_dummies)
    end          
end



function test_N_qubit_one_dummy_one_trap_N_dummies_small_prob_outcome_bit_flip(num_iterations,number_dummies,bit_flip_prob,trap_acceptance_threshold)
    # Create the the quantum experience
    quantum_env=QuEST.createQuESTEnv()  


    # Function to run the circuit
    function N_qubits_entangled_return_verification(quantum_env,number_dummies,bit_flip_prob)
        
        # Create the quantum state on 2 qubits
        num_traps = 1
        num_qubits = num_traps + number_dummies
        ρ = QuEST.createDensityQureg(num_qubits,quantum_env)
        
        
        # Trap and dummy draws
        r₀ = draw_rᵥ()
        θ₀ = draw_θᵥ()
        d = [draw_dᵥ() for i in Base.OneTo(number_dummies)]
        dθ = [draw_θᵥ() for i in Base.OneTo(number_dummies)] 
        
        
        # Trap qubit 0
        q₀ = 0
        QuEST.hadamard(ρ,q₀)
        QuEST.phaseShift(ρ,q₀,θ₀)


        # Initialise qubits
        # qubits 1 to N
        for i in Base.OneTo(number_dummies)
            d[i] == 1 ? QuEST.pauliX(ρ,i) : nothing
        end

        
        # Entangle the circuits
        for i in Base.OneTo(number_dummies)
            QuEST.controlledPhaseFlip(ρ,q₀,i)
        end

        
        # Measure qubit 0 trap
        δ₀ = θ₀ + r₀*π
        QuEST.rotateZ(ρ,q₀,-δ₀)
        QuEST.hadamard(ρ,q₀)
        b₀ = QuEST.measure(ρ,q₀)

        r = rand()
        b₀ = r < bit_flip_prob ? abs(1-b₀) : b₀
        


        # Measure qubit 1 to N dummies
        for i in Base.OneTo(number_dummies)
            QuEST.rotateZ(ρ,i,-dθ[i] )
            QuEST.hadamard(ρ,i)
            QuEST.measure(ρ,i)
        end


        # Destroy register
        QuEST.destroyQureg(ρ, quantum_env) 
        
        # Verify
        verification_values = reduce(vcat,(b₀,r₀,d))
        mod(sum(verification_values),2)
        
    end
    
    # Verify circuit
    
    verification_results = []
    for i in Base.OneTo(num_iterations)
        vr = N_qubits_entangled_return_verification(quantum_env,number_dummies,bit_flip_prob)
        push!(verification_results,vr)
    end 
    
    verified_decimal = count(==(0),verification_results)./num_iterations
     @test verified_decimal > trap_acceptance_threshold
end

function test_graph_colouring_label(N,reps)
    graph = Graphs.complete_graph(N)
    colourings_struct = Graphs.random_greedy_color(graph, reps)
    colouring = map(x-> Int.(colourings_struct.colors .== x).+1,Base.OneTo(colourings_struct.num_colors))
    @test colourings_struct.num_colors == N
    # Complete graph N vertices, there are N two coloring vectors
    @test length(colouring) == N
    [@test size(count(==(2),i),1)==1 for i in colouring]
end




function test_number_round_types()
    for i in Base.OneTo(10_000)
        total_rounds = 1_000
        computation_rounds = rand(1:total_rounds)
        round_types = draw_random_rounds(total_rounds,computation_rounds)
        counts = map(i->count(x-> x isa i,round_types),[ComputationRound,TestRound])
        @test sum(counts) == total_rounds
        @test counts == [computation_rounds, total_rounds - computation_rounds]
    end
end



function test_two_qubit_verification_from_meta_graph()
    # Create client resource
    is_density=true
    input_indices = ()
    input_values = ()
    output_indices = 0
    cols,rows = 2,1
    graph = Graphs.grid([cols,rows])
    reps = 100
    computation_colours = ones(nv(graph))
    test_colours = get_vector_graph_colors(graph;reps=reps)
    num_vertices = nv(graph)
    angles = [draw_θᵥ() for i in vertices(graph)]
    forward_flow(vertex) = vertex + rows
    backward_flow(vertex) = vertex - rows
    p = (input_indices = input_indices,input_values = input_values,
        output_indices = output_indices,graph=graph,computation_colours=computation_colours,test_colours=test_colours,
        angles = angles,forward_flow = forward_flow,backward_flow=backward_flow)
    client_resource = create_graph_resource(p)
    state_type = DensityMatrix()
    total_rounds,computation_rounds = 10_000,0
    round_types = draw_random_rounds(total_rounds,computation_rounds)
    


    # Iterate over rounds
    for round_type in round_types
        
        # Generate client meta graph
        client_meta_graph = generate_property_graph!(Client(),round_type,client_resource,state_type)
        
        

        # Extract graph and qureg from client
        client_graph = produce_initialised_graph(Client(),client_meta_graph)
        client_qureg = produce_initialised_qureg(Client(),client_meta_graph)

        # Create server resources
        server_resource = create_resource(Server(),client_graph,client_qureg)

        server_quantum_state = server_resource["quantum_state"]
        num_qubits_from_server = server_quantum_state.numQubitsRepresented

        for q in Base.OneTo(num_qubits_from_server)
            
            ϕ = get_updated_ϕ!(Client(),client_meta_graph,q)
            m = measure_along_ϕ_basis!(Server(),server_quantum_state,q,ϕ)
            store_measurement_outcome!(Client(),client_meta_graph,q,m)
        end
        
        vertex_type = get_prop(client_meta_graph,1,:vertex_type)
        if vertex_type isa TrapQubit
            d = get_prop(client_meta_graph,2,:init_qubit)
            r = get_prop(client_meta_graph,1,:one_time_pad_int)
            b = get_prop(client_meta_graph,1,:outcome)
            @test mod(sum([d,r,b]),2) == 0
        else
            d = get_prop(client_meta_graph,1,:init_qubit)
            r = get_prop(client_meta_graph,2,:one_time_pad_int)
            b = get_prop(client_meta_graph,2,:outcome)
            @test mod(sum([d,r,b]),2) == 0
        end

    end

end


function test_three_qubit_verification_from_meta_graph()
    # Create client resource
    is_density=true
    input_indices = ()
    input_values = ()
    output_indices = 0
    cols,rows = 1,3
    graph = Graphs.grid([cols,rows])
    reps = 100
    computation_colours = ones(nv(graph))
    test_colours = get_vector_graph_colors(graph;reps=reps)
    num_vertices = nv(graph)
    angles = [draw_θᵥ() for i in vertices(graph)]
    forward_flow(vertex) = vertex + rows
    backward_flow(vertex) = vertex - rows
    p = (input_indices = input_indices,input_values = input_values,
        output_indices = output_indices,graph=graph,computation_colours=computation_colours,test_colours=test_colours,
        angles = angles,forward_flow = forward_flow,backward_flow=backward_flow)
    client_resource = create_graph_resource(p)
    state_type = DensityMatrix()
    total_rounds,computation_rounds = 10_000,0
    round_types = draw_random_rounds(total_rounds,computation_rounds)
    round_graphs = []


    #contruct_coloring_plot_for_no_colors(graph)
    #colouring = generate_random_greedy_color(graph,reps)
    #contruct_coloring_plot_for_all_colors(graph,colouring.colors)
    #rand_color_vector = get_vector_graph_colors(graph;reps=reps)[1]
    #contruct_coloring_plot_for_one_color(graph,rand_color_vector)

    # Iterate over rounds
    for round_type in round_types
        
        # Generate client meta graph
        client_meta_graph = generate_property_graph!(Client(),round_type,client_resource,state_type)
        
        

        # Extract graph and qureg from client
        client_graph = produce_initialised_graph(Client(),client_meta_graph)
        client_qureg = produce_initialised_qureg(Client(),client_meta_graph)

        # Create server resources
        server_resource = create_resource(Server(),client_graph,client_qureg)
        server_quantum_state = server_resource["quantum_state"]
        num_qubits_from_server = server_quantum_state.numQubitsRepresented

        for q in Base.OneTo(num_qubits_from_server)
            ϕ = get_updated_ϕ!(Client(),client_meta_graph,q)
            m = measure_along_ϕ_basis!(Server(),server_quantum_state,q,ϕ)
            store_measurement_outcome!(Client(),client_meta_graph,q,m)
        end
        push!(round_graphs,client_meta_graph)
    end

    @test [get_prop(g,:round_type) for g in round_graphs] == round_types

    ground=0
    for rt in round_types
        ground+=1        
        
        rt isa ComputationRound && continue
        g = round_graphs[ground]
        vertex_types = [get_prop(g,i,:vertex_type) for i in vertices(g)]
        

        if vertex_types == [TrapQubit(),DummyQubit(),TrapQubit()]
        
            tdt = g
            b₁ = get_prop(tdt,1,:outcome)
            b₃ = get_prop(tdt,3,:outcome)
            r₁ = get_prop(tdt,1,:one_time_pad_int)
            r₃ = get_prop(tdt,3,:one_time_pad_int)
            n₁ = all_neighbors(tdt,1)
            n₃ = all_neighbors(tdt,3)
            d₂ = [get_prop(tdt,n,:init_qubit) for n in n₁][1]
            d₂ = [get_prop(tdt,n,:init_qubit) for n in n₃][1]        
            @test mod(sum([b₁,r₁,d₂]),2)==0 & mod(sum([b₃,r₃,d₂]),2)==0
            
        elseif vertex_types == [DummyQubit(),TrapQubit(),DummyQubit()]
            
            dtd = g
            b₂ = get_prop(dtd,2,:outcome)
            r₂ = get_prop(dtd,2,:one_time_pad_int)
            n₂ = all_neighbors(dtd,2)
            d₁₃ = [get_prop(dtd,n,:init_qubit) for n in n₂]

            @test mod(sum(reduce(vcat,[b₂,r₂,d₁₃])),2)==0 
            
        else 
            @error "Qubits are not correct"
        end
    end

end
