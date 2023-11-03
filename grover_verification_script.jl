##################################################################
# Filename  : grovers_verification_example.jl
# Author    : Jonathan Miller
# Date      : 2023-11-03
# Aim       : The pluto notebook is an expanded version
#           : to show the Grovers algorithm works on the verification
#           : simulator. This script is a trimmed down version.
##################################################################


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

include("src/QuESTMbqcBqpVerification.jl")
using .QuESTMbqcBqpVerification 

#using QuESTMbqcBqpVerification 

# Function to add to QuESTMbqcBqpVerification 
function initialise_blank_quantum_state!(quantum_state)
    QuEST.initBlankState(quantum_state)
end

# Function to generate angles defining what search is completed
function generate_angles(p)
    ϕ₃,ϕ₄ = p
    [0,0,1.0*ϕ₃,1.0*ϕ₄,0,0,1.0*π,1.0*π]
end


state_type = StateVector()#DensityMatrix()
input_indices = () # a tuple of indices 
input_values = () # a tuple of input values
output_indices = (7,8) # Grovers: 7,8



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

# Define colouring
reps = 100
computation_colours = ones(nv(graph))
test_colours = get_vector_graph_colors(graph;reps=reps)



search = "01"
angle = Dict("00"=>(1.0*π,1.0*π),"01"=>(1.0*π,0),"10"=>(0,1.0*π),"11"=>(0,0))
secret_angles = Float64.(generate_angles(angle[search]))
public_angles = [draw_θᵥ() for i in Base.OneTo(8)]

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


function backward_flow(vertex)
    v_str = string(vertex)
    backward = Dict(
        "1" =>0,
        "2" =>0,
        "3" =>2,
        "4" =>1,
        "5" =>4,
        "6" =>3,
        "7" =>6,
        "8" =>5)
    backward[v_str]
end


	p = (
		input_indices = input_indices,
		input_values = input_values,
	    output_indices =output_indices,
		graph=graph,
		computation_colours=computation_colours,
		test_colours=test_colours,
	    public_angles = public_angles,
		secret_angles=secret_angles,
		forward_flow = forward_flow,
		backward_flow=backward_flow)

client_resource = create_graph_resource(p)


total_rounds,computation_rounds = 100,50
round_types = draw_random_rounds(total_rounds,computation_rounds)


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
        if round_type isa ComputationRound
            r = get_prop(client_meta_graph,q,:one_time_pad_int)
            m = abs(m-r)	
        end
        store_measurement_outcome!(Client(),client_meta_graph,q,m)
    end
        
    initialise_blank_quantum_state!(server_quantum_state)

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
        output_inds = get_prop(mg,:output_inds)
        outcome = []
        for v in output_inds
                classic_outcome = get_prop(mg,v,:outcome)
                push!(outcome,classic_outcome)
        end
        push!(computation_outcomes,outcome)
    end
end




rounds = []
for mg in round_graphs 
    push!(rounds,get_prop(mg,:round_type))
end
round_type_counts = map(y->count(x-> x isa y, rounds), [ComputationRound,TestRound])
f_rc = Figure(resolution = (400,400))
ax_rc = Axis(f_rc[1,1], xlabel = "Round", ylabel = "Count", title = "Round Counts", xticks = ([1,2], ["Computation","Test"]))
barplot!(ax_rc,[1,2],round_type_counts)
f_rc
#save("figures/round_counts.pdf",f_rc)
#save("figures/round_counts.png",f_rc)




mod_res = mode(computation_outcomes)
num_match_mode = count(==(mod_res),computation_outcomes)
num_not_match_mode = count(!=(mod_res),computation_outcomes)
comp_results = [num_match_mode,num_not_match_mode]
f_cr = Figure(resolution = (400,400))
ax_cr = Axis(f_cr[1,1], xlabel = "Outcome", ylabel = "Count", title = "Computation Round Results", xticks = ([1,2], ["Passed","Failed"]))
barplot!(ax_cr,[1,2],comp_results)
f_cr
#save("figures/computation_outcomes.pdf",f_cr)
#save("figures/computation_outcomes.png",f_cr)

	

results = map(y->count(x->x == y,test_verifications),[1,0])
f_tr = Figure(resolution = (400,400))
ax_tr = Axis(f_tr[1,1], xlabel = "Outcome", ylabel = "Count", title = "Test Round Results", xticks = ([1,2], ["Passed","Failed"]))
barplot!(ax_tr,[1,2],results)
f_tr
#save("figures/test_outcomes.pdf",f_tr)
#save("figures/test_outcomes.png",f_tr)

