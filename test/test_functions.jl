
function test_mbqc()
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


    # Initial setups
    mbqc_comp_type = MeasurementBasedQuantumComputation(qgraph,flow,measurement_angles)
    no_network = NoNetworkEmulation()
    dm = DensityMatrix()
    sv = StateVector()
    ch = NoisyChannel(NoNoise(NoQubits()))
    cr = MBQCRound()



    outcomes_dm = []
    outcomes_sv = []
    for i in Base.OneTo(10)
        mg_dm = compute!(mbqc_comp_type,no_network,dm,ch,cr)
        mg_sv = compute!(mbqc_comp_type,no_network,sv,ch,cr)
        push!(outcomes_dm,get_prop(mg_dm,2,:outcome))
        push!(outcomes_sv,get_prop(mg_sv,2,:outcome))
    end


    @test all([i == 0 for i in outcomes_dm])
    @test all([i == 0 for i in outcomes_sv])

end



function test_ubqc()

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


    # Initial setups
    ubqc_comp_type = BlindQuantumComputation(qgraph,flow,measurement_angles)
    dm = DensityMatrix()
    ch = NoisyChannel(NoNoise(NoQubits()))
    cr = ComputationRound()



    # Implicit network
    implicit_network = ImplicitNetworkEmulation()
    outcomes_imp_net = []
    for i in Base.OneTo(10)
        mg_imp = compute!(ubqc_comp_type,implicit_network,dm,ch,cr)
        push!(outcomes_imp_net,get_prop(mg_imp,2,:outcome))
    end

    @test all([i == 0 for i in outcomes_imp_net])



    # Bell pair network
    bell_pair_explicit_network = BellPairExplicitNetwork()
    outcomes_bel_net = []
    for i in Base.OneTo(10)
        mg_bp = compute!(ubqc_comp_type,bell_pair_explicit_network,dm,ch,cr)
        push!(outcomes_bel_net,get_prop(mg_bp,2,:outcome))
    end


    @test all([i == 0 for i in outcomes_bel_net])


end


function test_vbqc()

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
        @test ver_res1.tests isa Ok
        @test ver_res2.tests isa Ok
    end

    vr = run_verification_simulator(ct,nt_bp,st,ch)
    @test get_tests(vr) isa Ok
    @test get_computations(vr) isa Ok
end