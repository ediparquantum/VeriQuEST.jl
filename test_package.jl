using Pkg
Pkg.activate(".")

include("src/QuESTMbqcBqpVerification.jl")
using .QuESTMbqcBqpVerification

using QuEST_jl
import QuEST_jl.QuEST64
QuEST = QuEST_jl.QuEST64
qreal = QuEST.QuEST_Types.qreal
using Test

using MetaGraphs
using CairoMakie
using GraphMakie
using GraphMakie.NetworkLayout
using Colors

struct Ok end
struct Abort end
struct TrapPass end
struct TrapFail end  

# Create client resource
state_type = DensityMatrix()
input_indices = () # a tuple of indices 
input_values = () # a tuple of input values
output_indices = () # any output values 

cols,rows = 2,2 
graph = Graphs.grid([cols,rows])
reps = 100
computation_colours = ones(nv(graph))
test_colours = get_vector_graph_colors(graph;reps=reps)
num_vertices = nv(graph)


angles = [draw_θᵥ() for i in vertices(graph)]

forward_flow(vertex) = vertex + rows
backward_flow(vertex) = vertex - rows


p = (
    input_indices = input_indices,
    input_values = input_values,
    output_indices =output_indices,
    graph=graph,
    computation_colours=computation_colours,
    test_colours=test_colours,
    angles = angles,
    forward_flow = forward_flow,
    backward_flow=backward_flow)

client_resource = create_graph_resource(p)

total_rounds,computation_rounds = 100,50
round_types = draw_random_rounds(total_rounds,computation_rounds)

round_type = round_types[1] 
# Generate client meta graph
client_meta_graph = generate_property_graph!(
    Client(),
    round_type,
    client_resource,
    state_type)


    
    round_graphs = []
    for round_type in round_types
        
        # Generate client meta graph
        client_meta_graph = generate_property_graph!(
            Client(),
            round_type,
            client_resource,
            state_type)
        
        
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
    

    computation_outcomes = []
	test_verifications = []
	for mg in round_graphs 
	    round_type = get_prop(mg,:round_type)
	    if round_type isa TestRound
			trap_results = []
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
					ver_res = mod(sum(reduce(vcat,[bᵥ,rᵥ,Dₙ])),2) == 0
					trap_res = ver_res ? TrapPass() : TrapFail()
					push!(trap_results,trap_res)
	                @test ver_res
	            end
	        end
			# 1 the round is good, 0 the round is bad
			round_res = all([t isa TrapPass for t in trap_results]) ? 1 : 0
			
			push!(test_verifications,round_res)
		elseif round_type isa ComputationRound
			outcome = []
 			for v in vertices(mg)
				push!(outcome,get_prop(mg,v,:outcome))
			end
			push!(computation_outcomes,outcome)
		end
	end

    using StatsBase
	mod_res = mode(computation_outcomes)
	num_match_mode = count(==(mod_res),computation_outcomes)
	num_not_match_mode = count(!=(mod_res),computation_outcomes)
	
	comp_results = [num_match_mode,num_not_match_mode]

	f_cr = Figure(resolution = (400,400))
	ax_cr = Axis(f_cr[1,1], xlabel = "Outcome", ylabel = "Count", title = "Computation Round Results", xticks = ([1,2], ["Passed","Failed"]))
	barplot!(ax_cr,[1,2],comp_results)
	f_cr