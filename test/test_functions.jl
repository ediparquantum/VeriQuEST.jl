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
    @test P isa Phase
    @test NO isa NoPhase
    @test QIS isa QubitInitialState
    @test BA isa BasisAngle
    @test MOC isa MeasurementOutcome
    @test AL isa AdjacencyList
    @test SR isa Server

    @test MR.angles isa MBQCAngles
    @test MR.angles.secret_angles isa Tuple
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




function test_is_round_OK()
    trap_results = [1,1,1,1]
    @test is_round_OK(trap_results)
    trap_results = [1,1,1,0]
    @test !is_round_OK(trap_results)
    trap_results = [0,0,0,0]
    @test !is_round_OK(trap_results)
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
    secret_angles = [draw_θᵥ() for i in vertices(graph)]
    forward_flow(vertex) = vertex + rows
    backward_flow(vertex) = vertex - rows
    p = (input_indices = input_indices,input_values = input_values,
        output_indices = output_indices,graph=graph,computation_colours=computation_colours,test_colours=test_colours,
        secret_angles = secret_angles,forward_flow = forward_flow,backward_flow=backward_flow)
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
    secret_angles = [draw_θᵥ() for i in vertices(graph)]
    forward_flow(vertex) = vertex + rows
    backward_flow(vertex) = vertex - rows
    p = (input_indices = input_indices,input_values = input_values,
        output_indices = output_indices,graph=graph,computation_colours=computation_colours,test_colours=test_colours,
        secret_angles = secret_angles,forward_flow = forward_flow,backward_flow=backward_flow)
    client_resource = create_graph_resource(p)
    state_type = DensityMatrix()
    total_rounds,computation_rounds = 10_000,0
    round_types = draw_random_rounds(total_rounds,computation_rounds)
    round_graphs = []


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


function test_grover_blind_verification()

    function run_grover_per_search(search)
        # Choose backend and round counts
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

        function generate_grover_secret_angles(search)

            Dict("00"=>(1.0*π,1.0*π),"01"=>(1.0*π,0),"10"=>(0,1.0*π),"11"=>(0,0)) |>
            x -> x[search] |>
            x -> [0,0,1.0*x[1],1.0*x[2],0,0,1.0*π,1.0*π] |>
            x -> Float64.(x)
        end
    

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

        int_search = [parse(Int,search[1]),parse(Int,search[2])]
        # Run grover search on mbqc and ubqc
        mbqc_outcome = run_mbqc(para)
        ubqc_outcome = run_ubqc(para)
        @test mbqc_outcome == ubqc_outcome
        @test all(mbqc_outcome .== int_search)
        @test all(ubqc_outcome .== int_search)

        # Run grover search on verification simulator with a TrustworthyServer
        vbqc_outcome = run_verification_simulator(TrustworthyServer(),Verbose(),para)

        test_rounds = total_rounds - computation_rounds
        @test vbqc_outcome[:test_verification] == Ok()
        @test vbqc_outcome[:computation_verification] == Ok()
        @test all(vbqc_outcome[:mode_outcome] .== int_search)
        @test vbqc_outcome[:test_verification_verb][:failed] == 0
        @test vbqc_outcome[:test_verification_verb][:passed] == test_rounds 
        @test vbqc_outcome[:computation_verification_verb][:failed] == 0
        @test vbqc_outcome[:computation_verification_verb][:passed] == computation_rounds


        
    end


    
    search = ["00","01","10","11"]
    run_grover_per_search.(search)
end

function test_compute_backward_flow()
    graph = Graph(3)
    add_edge!(graph,1,2)
    add_edge!(graph,2,3)
 

    function forward_flow(vertex)
        v_str = string(vertex)
        forward = Dict(
            "1" =>2,
            "2" =>3,
            "3" =>0)
        forward[v_str]
    end


   
    backward_flow(vertex) = compute_backward_flow(graph,forward_flow,vertex)
    @test backward_flow(3) == 2
    @test backward_flow(2) == 1
    @test backward_flow(1) == 0
end