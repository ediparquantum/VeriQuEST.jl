##################################################################
# Filename  : 20230918_VerificationTesting_V1.jl
# Author    : Jonathan Miller
# Date      : 2023-09-29
# Aim       : Verify grid graph 2x2
#           : Build functionality to verify rounds
#           : build function to wrap a single round 
#           : then loop that one line
##################################################################

# Packages used
using Pkg
Pkg.activate(".")
using QuESTMbqcBqpVerification 
using QuEST_jl
import QuEST_jl.QuEST64
QuEST = QuEST_jl.QuEST64
qreal = QuEST.QuEST_Types.qreal
using Test




# Create client resource
is_density=true
input_indices = ()
input_values = ()
output_indices = 0
cols,rows = 2,2
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
total_rounds,computation_rounds = 2,1
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


for mg in round_graphs 
    round_type = get_prop(mg,:round_type)
    if round_type isa TestRound
        verified_bᵥ_rᵥ_dᵥ = []
        for v in vertices(mg)
            v_type = get_prop(mg,v,:vertex_type)
            if v_type isa TrapQubit
                neighs = all_neighbors(mg,v)
                bᵥ = get_prop(mg,v,:outcome)
                rᵥ = get_prop(mg,v,:one_time_pad_int)
                Dₙ = []
                for n in neighs
                    dₙ = get_prop(mg,n,:init_qubit)
                    push!(Dₙ,dₙ)
                end
                @test mod(sum(reduce(vcat,[bᵥ,rᵥ,Dₙ])),2) == 0    
            
            end
        end
    end
end

