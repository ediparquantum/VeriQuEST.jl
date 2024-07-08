##################################################################
# Filename  : network_emulation.jl
# Author    : Jonathan Miller
# Date      : 2024-03-12
# Aim       : aim_script
#           : All network related code
#           : Also state initilisation
##################################################################









##################################################################
# Type associated function: AbstractNetworkEmulation
##################################################################
// # functions
    function get_quantum_backend(em::AbstractNetworkEmulation)
        em.qureg
    end
    function set_quantum_backend!(em::AbstractNetworkEmulation,qureg::Qureg)
        em.qureg = qureg
    end

    function get_num_qubits(em::AbstractNetworkEmulation)
        qureg = get_quantum_backend(em)
        QuEST.get_num_qubits(qureg)
    end

    function get_qubit_range_one_to_n(em::AbstractNetworkEmulation)
        num_qubits = get_num_qubits(em)
        Base.OneTo(num_qubits)
    end

    function get_qureg_matrix(ane::AbstractNetworkEmulation)
        qureg = get_quantum_backend(ane)
        QuEST.get_qureg_matrix(qureg)
    end

// # end


##################################################################
# Type associated function: 
#            AbstractExplicitNetworkEmulation
#            AbstractImplicitNetworkEmulation
##################################################################
// # functions
    T = Union{AbstractExplicitNetworkEmulation,AbstractImplicitNetworkEmulation}
    function get_qubit_types(bpen::T)
        bpen.qubit_types
    end
     
    function set_qubit_types!(bpen::T,qubit_types::Vector{Union{ComputationQubit,TrapQubit,DummyQubit}})
        bpen.qubit_types = qubit_types
    end 

    function get_basis_init_angles(bpen::T)
        bpen.basis_init_angles
    end

    function set_basis_init_angles!(bpen::T,init_angles::Union{Vector{Float64},Vector{Union{Int,Int64,Float64}}})
        bpen.basis_init_angles = init_angles
    end

    function get_client_indices(bpen::T)
        bpen.client_indices
    end

    function set_client_indices!(bpen::T,client_indices::Vector{Union{Int,Int64}})
        bpen.client_indices = client_indices
    end

    function get_server_indices(bpen::T)
        server_indices = bpen.server_indices
        if server_indices isa Missing
            return get_qubit_range_one_to_n(bpen)
        else
            return server_indices
        end
    end

    function set_server_indices!(bpen::T,server_indices::Vector{Union{Int,Int64}})
        bpen.server_indices = server_indices
    end


    function get_num_qubits(num_vertices::Int,::Union{AbstractNoNetworkEmulation,AbstractImplicitNetworkEmulation}) 
        num_vertices
    end

    function get_num_qubits(num_vertices::Int,::AbstractBellPairExplicitNetwork) 
        num_vertices + 1
    end

    function set_qubit_types!(bpen::T,qubit_types::Union{Vector{AbstractQubitType},Missing,Vector{Missing}, Vector{ComputationQubit}})
        bpen.qubit_types = qubit_types
    end

// # end


##################################################################
# Type associated function: BellPair
##################################################################
// # functions
    mutable struct BellPair <: AbstractBellPairExplicitNetwork
        client_idx::Union{Int,Int64,Missing}
        server_idx::Union{Int,Int64,Missing}

        function BellPair()
            new(missing,missing)
        end

        function BellPair(client_idx)
            new(client_idx,missing)
        end

        function BellPair(client_idx,server_idx)
            new(client_idx,server_idx)
        end
    end


    function get_client_idx(bp::BellPair)
        bp.client_idx
    end

    function get_server_idx(bp::BellPair)
        bp.server_idx
    end

    function set_client_idx!(bp::BellPair,idx::Union{Int,Int64})
        bp.client_idx = idx
    end

    function set_server_idx!(bp::BellPair,idx::Union{Int,Int64})
        bp.server_idx = idx
    end


// # end


##################################################################
# Type associated function: NoNetworkEmulation
##################################################################

// # functions
    mutable struct NoNetworkEmulation <: AbstractNoNetworkEmulation
        qureg::Union{Qureg,Missing}
        function NoNetworkEmulation()
            new(missing)
        end
        function NoNetworkEmulation(qureg)
            new(qureg)
        end
    end

    function get_server_size(nm::NoNetworkEmulation)
        # Num qubits is server size
        get_num_qubits(nm) 
    end
// # end



##################################################################
# Type associated function: ImplicitNetworkEmulation
##################################################################

// # functions
    mutable struct ImplicitNetworkEmulation <: AbstractImplicitNetworkEmulation
        qureg::Union{Qureg,Missing}
        qubit_types::Union{Vector{AbstractQubitType},Missing,Vector{Missing}, Vector{ComputationQubit}}
        client_indices::Union{Int,Int64,Vector{Union{Int,Int64}},Missing,Vector{Missing}}
        server_indices::Union{Int,Int64,Vector{Union{Int,Int64}},Missing,Vector{Missing}}
        basis_init_angles::Union{Float64, Int64, Vector{Float64}, Vector{Int64}, Missing,Vector{Missing}}
        function ImplicitNetworkEmulation()
            new(missing,missing,missing,missing,missing)
        end

        function ImplicitNetworkEmulation(qureg,qubit_types,client_indices,server_indices,basis_init_angles)
            new(qureg,qubit_types,client_indices,server_indices,basis_init_angles)
        end

        function ImplicitNetworkEmulation(qureg,qubit_types,basis_init_angles)
            new(qureg,qubit_types,missing,missing,basis_init_angles)
        end
    end

    function get_client_size(im::ImplicitNetworkEmulation)
        client = get_client_indices(im) 
        if client isa Missing || client isa Vector{Missing}
            return 0        
        elseif !(client isa Missing || client isa Vector{Missing})
            @error "Client is not type Missing, specifivally it is: $(typeof(client)). Client indices are not admitted in an implicit network."  
        else
            @error "Client is not missing nor is it missing. It is: $(typeof(client)). Please look at `get_client_size(im::ImplicitNetworkEmulation)` for problem."
        end
    end

    function get_server_size(im::ImplicitNetworkEmulation)
        server = get_server_indices(im) 
        if server isa Missing || server isa Vector{Missing}
            @error "Server is type Missing, specifivally: $(typeof(server)). Server indices are required."            
        else
            return length(server)
        end
    end

    



// # end


##################################################################
# Type associated function: ExplicitNetworkEmulation
##################################################################
// # functions
    mutable struct ExplicitNetworkEmulation <: AbstractExplicitNetworkEmulation
        qureg::Union{Qureg,Missing}
        qubit_types::Union{Vector{AbstractQubitType},Missing,Vector{Missing},Vector{ComputationQubit}}
        client_indices::Union{Int,Int64,Vector{Union{Int,Int64}},Missing,Vector{Missing}}
        server_indices::Union{Int,Int64,Vector{Union{Int,Int64}},Missing,Vector{Missing}}
        basis_init_angles::Union{Float64, Int64, Vector{Float64}, Vector{Int64}, Missing,Vector{Missing}}
        function ExplicitNetworkEmulation()
            new(missing,missing,missing,missing,missing)
        end
        function ExplicitNetworkEmulation(qureg,qubit_types,client_indices,server_indices,basis_init_angles)
            new(qureg,qubit_types,client_indices,server_indices,basis_init_angles)
        end
        function ExplicitNetworkEmulation(qureg,qubit_types,client_indices,basis_init_angles)
            num_qubits = get_num_qubits(qureg)
            server_indices = setdiff(1:num_qubits,client_indices)
            @assert length(server_indices) > 0 "Server indices are empty. Please check client indices and number of qubits."
            @assert length(server_indices) == length(qubit_types) "Server indices and qubit types are not the same length."
            @assert length(server_indices) == length(basis_init_angles) "Server indices and basis init angles are not the same length."
            new(qureg,qubit_types,client_indices,server_indices,basis_init_angles)
        end
    end


    function get_client_size(im::ExplicitNetworkEmulation)
        client = get_client_indices(im) 
        if client isa Missing || client isa Vector{Missing}
            @error "Client type Missing, specifivally it is: $(typeof(client)). Client indices are required in an explicit network."        
        elseif !(client isa Missing || client isa Vector{Missing})
            return length(client)
        else
            @error "Client is not missing nor is it missing. It is: $(typeof(client)). Please look at `get_client_size(im::ExplicitNetworkEmulation)` for problem."
        end
    end

    function get_server_size(im::ExplicitNetworkEmulation)
        server = get_server_indices(im) 
        if server isa Missing || server isa Vector{Missing}
            @error "Server is type Missing, specifivally: $(typeof(server)). Server indices are required."            
        else
            return length(server)
        end
    end

// # end



##################################################################
# Type associated function: BellPairExplicitNetwork
##################################################################
// # functions
    mutable struct BellPairExplicitNetwork <: AbstractBellPairExplicitNetwork 
        qureg::Union{Qureg,Missing}
        qubit_types::Union{Vector{AbstractQubitType},Missing,Vector{Missing},Vector{ComputationQubit}}
        client_indices::Union{Int,Int64,Vector{Union{Int,Int64}},Missing,Vector{Missing}}
        server_indices::Union{Int,Int64,Vector{Union{Int,Int64}},Missing,Vector{Missing}}
        basis_init_angles::Union{Float64, Int64, Vector{Float64}, Vector{Int64}, Missing,Vector{Missing}}
        bell_pairs::Union{BellPair,Vector{BellPair},Missing,Vector{Missing}}
        function BellPairExplicitNetwork()
            new(missing,missing,missing,missing,missing,missing)
        end
        function BellPairExplicitNetwork(qureg,qubit_types,client_indices,server_indices,basis_init_angles,bell_pairs)
            new(qureg,qubit_types,client_indices,server_indices,basis_init_angles,bell_pairs)
        end
        function BellPairExplicitNetwork(qureg,qubit_types,client_indices,basis_init_angles)
            @assert length(client_indices) == 1 "BellPairExplicitNetwork requires one client index, not $(length(client_indices))."
            if client_indices isa Vector
                client_indices = client_indices[1]
            end
            num_qubits = get_num_qubits(qureg)
            server_indices = setdiff(1:num_qubits,client_indices)
            @assert length(server_indices) > 0 "Server indices are empty. Please check client indices and number of qubits."
            @assert length(server_indices) == length(qubit_types) "Server indices and qubit types are not the same length."
            @assert length(server_indices) == length(basis_init_angles) "Server indices and basis init angles are not the same length."
            bell_pairs = [BellPair(client_indices,s) for s in server_indices]
            @assert length(bell_pairs) == length(server_indices) "Server indices and bell pairs are not the same length."

            new(qureg,qubit_types,client_indices,server_indices,basis_init_angles,bell_pairs)
        end
    end

    function compute_server_indices(bpen::BellPairExplicitNetwork)
        total_qubit_range = bpen |> 
        get_num_qubits |>
        Base.OneTo
        client_idx = get_client_indices(bpen)
        setdiff(total_qubit_range,client_idx)
    end

    function set_server_indices!(bpen::BellPairExplicitNetwork)
        server_indices = compute_server_indices(bpen)
        set_server_indices!(bpen,server_indices)
    end
    
   

    function get_bell_pairs(bpen::BellPairExplicitNetwork)
        bpen.bell_pairs
    end

    function set_bell_pairs!(bpen::BellPairExplicitNetwork,bp::Vector{BellPair})
        bpen.bell_pairs = bp
    end

    function compute_bell_pairs(bpen::BellPairExplicitNetwork)
        server_indices = get_server_indices(bpen)
        client_idx = get_client_indices(bpen)[1]
        [BellPair(client_idx,s) for s in server_indices]
    end

    function set_bell_pairs!(bpen::BellPairExplicitNetwork)
        bell_pairs = compute_bell_pairs(bpen)
        set_bell_pairs!(bpen,bell_pairs)
    end


    function get_client_idx(bpen::BellPairExplicitNetwork)
        ci = bpen.client_indices
        @assert length(ci) == 1 "Only one qubit is used for BellPairExplicitNetwork"
        ci
    end

    function get_server_idx(bpen::BellPairExplicitNetwork)
       si = bpen.server_indices
       @assert !isempty(si) "Server indices can not be empty"
    end

    function get_qubit_types(bpen::BellPairExplicitNetwork)
        bpen.qubit_types
    end




  
    function set_client_idx!(bpen::BellPairExplicitNetwork,idx::Union{Int,Int64})
        bell_pair = get_bell_pairs(bpen)
        set_client_idx!(bell_pair,idx)
        set_bell_pair!(bpen,bell_pair)
    end

    function set_server_idx!(bpen::BellPairExplicitNetwork,idx::Union{Int,Int64})
        bell_pair = get_bell_pairs(bpen)
        set_server_idx!(bell_pair,idx)
        set_bell_pair!(bpen,bell_pair)
    end

    function get_init_angle_index(bpen::BellPairExplicitNetwork)
        get_server_idx(bpen)
    end

    function get_init_angle(bpen::BellPairExplicitNetwork)
        idx = get_init_angle_index(bpen)
        bpen |>
        get_basis_init_angles |>
        x -> x[idx]
    end

    function get_server_size(bpen::BellPairExplicitNetwork)
        get_num_qubits(bpen) - 1 # One qubit is the  client 
    end

    function max_damping!(bpen::BellPairExplicitNetwork)
        qureg = get_quantum_backend(bpen)
        client_idx = get_client_idx(bpen)
        server_idx = get_server_idx(bpen)
        max_damping!(qureg,client_idx)
        max_damping!(qureg,server_idx)
    end
    
    function get_state_prep_angle(ne::BellPairExplicitNetwork,outcome::Union{Int32,Int64})
        get_init_angle(ne) + outcome*π + π |> x -> mod2pi(x) - 2*π
    end
    
    
    function measure(bpen::BellPairExplicitNetwork)
        qureg = get_quantum_backend(bpen)
        client_idx = get_client_idx(bpen)
        QuEST.measure(qureg,client_idx)
    end

    function Base.range(bpen::BellPairExplicitNetwork)
        num_qubits = get_num_qubits(bpen)
        qubits = Base.OneTo(num_qubits)
        client_idx = get_client_idx(bpen)
        setdiff(qubits,client_idx)
    end
    
    function pauliX(bpen::BellPairExplicitNetwork)
        qureg = get_quantum_backend(bpen)
        client_idx = get_client_idx(bpen)
        server_idx = get_server_idx(bpen)
        QuEST.pauliX(qureg,client_idx)
        QuEST.pauliX(qureg,server_idx)
    end
    
    function hadamard(bpen::BellPairExplicitNetwork)
        qureg = get_quantum_backend(bpen)
        client_idx = get_client_idx(bpen)
        QuEST.hadamard(qureg,client_idx)
    end
    
    function controlledNot(bpen::BellPairExplicitNetwork)
        qureg = get_quantum_backend(bpen)
        client_idx = get_client_idx(bpen) # Control
        server_idx = get_server_idx(bpen) # Target
        QuEST.controlledNot(qureg,client_idx,server_idx)  
    end
    
    function entangle!(bpen::BellPairExplicitNetwork)
        max_damping!(bpen)
        pauliX(bpen)
        hadamard(bpen)
        controlledNot(bpen)
    end  

// # end


##################################################################
# Type associated function: BasisSpecification
##################################################################
// # functions
    mutable struct BasisSpecification 
        qureg::Union{Qureg,Missing}
        qubit_type::Union{AbstractQubitType,Missing}
        client_idx::Union{Int,Int64,Missing}
        basis_init_angle::Union{Int,Int64,Float64,Missing}
        
        function BasisSpecification()
            new(missing,missing,missing,missing)
        end


        function BasisSpecification(bpen::BellPairExplicitNetwork)
            qureg = get_quantum_backend(bpen)
            qubit_type = get_qubit_type(bpen)
            client_idx = get_client_idx(bpen)
            basis_init_angle = get_init_angle(bpen)
            return new(qureg,qubit_type,client_idx,basis_init_angle)
        end

        function BasisSpecification(qureg,qubit_type,client_idx,basis_init_angle)
            new(qureg,client_idx,basis_init_angle)
        end
    end


    function get_quantum_backend(bm::BasisSpecification)
        bm.qureg
    end

    function get_client_idx(bm::BasisSpecification)
        bm.client_idx
    end

    function get_init_angle(bm::BasisSpecification)
        bm.basis_init_angle
    end

    function set_init_angle!(bm::BasisSpecification,angle::Float64)
        bm.basis_init_angle = angle
    end


    function rotate_neg_Z(bm::BasisSpecification)
        qureg = get_quantum_backend(bm)
        client_idx = get_client_idx(bm)
        θ = get_init_angle(bm)
        QuEST.rotateZ(qureg,client_idx,-θ)  
    end

    function hadamard(bm::BasisSpecification)
        qureg = get_quantum_backend(bm)
        client_idx = get_client_idx(bm)
        QuEST.hadamard(qureg,client_idx)
    end

    function apply_basis_change!(bm::BasisSpecification)
        rotate_neg_Z(bm)   
        hadamard(bm)
    end

    function get_qureg_matrix(bm::BasisSpecification)
        qureg = get_quantum_backend(bm)
        get_qureg_matrix(qureg)
    end

    function measure(bm::BasisSpecification)
        qureg = get_quantum_backend(bm)
        client_idx = get_client_idx(bm)
        QuEST.measure(qureg,client_idx)
    end
// # end

##################################################################
# Type associated function: InitialisedServer
##################################################################
// # functions
    struct InitialisedServer <: AbstractInitialisedServer
        qureg::Union{Qureg,Missing}
        server_indices::Union{Int,Int64,Vector{Union{Int,Int64}},Missing,Vector{Missing},Vector{Int32}}
        qubit_types::Union{Vector{AbstractQubitType},Missing,Vector{Missing},Vector{ComputationQubit}}
        adapted_prep_angles::Union{Vector{Float64},Missing}
        function InitialisedServer()
            new(missing,missing,missing,missing)
        end
        function InitialisedServer(qureg,server_indices,qubit_types,adapted_prep_angles)
            new(qureg,server_indices,qubit_types,adapted_prep_angles)
        end

        function InitialisedServer(qureg)
            new(qureg,missing,missing,missing)
        end

    end

    function get_quantum_backend(is::InitialisedServer)
        is.qureg
    end

    function set_quantum_backend!(is::InitialisedServer,qureg::Qureg)
        is.qureg = qureg
    end

    function get_qubit_range(is::InitialisedServer)
        is.server_indices
    end

    function get_qubit_types(is::InitialisedServer)
        is.qubit_types
    end

    function get_adapted_prep_angles(is::InitialisedServer)
        is.adapted_prep_angles
    end

// # end


##################################################################
# Quest functions require to pass the bell pair
##################################################################
// # functions
    function max_damping!(qureg::Qureg,qubit_idx::Union{Int,Int64})
        QuEST.mixDamping(qureg,qubit_idx,1.0)
    end

    function max_damping!(qureg::Qureg,bell_pair::BellPair)
        client_idx = get_client_idx(bell_pair)
        server_idx = get_server_idx(bell_pair)
        QuEST.mixDamping(qureg,client_idx,1.0)
        QuEST.mixDamping(qureg,server_idx,1.0)
    end

    function get_num_qubits(qureg::Qureg)
        QuEST.getNumQubits(qureg)
    end


    function init_state!(qureg::Qureg,qubit_type::ComputationQubit,qubit_index::Union{Int,Int32,Int64},initialisation::Float64) 
        QuEST.hadamard(qureg,qubit_index)
        QuEST.rotateZ(qureg,qubit_index,initialisation)
    end


    function init_state!(qureg::Qureg,qubit_type::TrapQubit,qubit_index::Union{Int,Int32,Int64},initialisation::Float64)
        QuEST.hadamard(qureg,qubit_index)
        QuEST.rotateZ(qureg,qubit_index,initialisation)
    end

    function init_state!(qureg::Qureg,qubit_type::DummyQubit,qubit_index::Union{Int,Int32,Int64},initialisation::Union{Float64,Int}) 
        Int(initialisation) == 0 ? qureg : QuEST.pauliX(qureg,qubit_index)
    end


 

    function pauliX(qureg::Qureg,bell_pair::BellPair)
        client_idx = get_client_idx(bell_pair)
        server_idx = get_server_idx(bell_pair)
        QuEST.pauliX(qureg,client_idx)
        QuEST.pauliX(qureg,server_idx)
    end

    function rotateZ(qureg::Qureg,bell_pair::BellPair,initialisation::Float64)
        client_idx = get_client_idx(bell_pair)
        QuEST.rotateZ(qureg,client_idx,initialisation)  
    end

    function hadamard(qureg::Qureg,bell_pair::BellPair)
        client_idx = get_client_idx(bell_pair)
        QuEST.hadamard(qureg,client_idx)
    end

    function controlledNot(qureg::Qureg,bell_pair::BellPair)
        client_idx = get_client_idx(bell_pair)
        server_idx = get_server_idx(bell_pair)
        QuEST.controlledNot(qureg,client_idx,server_idx)  
    end

    function measure(qureg::Qureg,bell_pair::BellPair)
        client_idx = get_client_idx(bell_pair)
        QuEST.measure(qureg,client_idx)
    end

    function get_state_prep_angle(outcome::Union{Int32,Int64},initialisation::Float64)
        initialisation + outcome*π + π |> x -> mod2pi(x) - 2*π
    end



    function entangle_tranfer_get_prep_state!(qureg::Qureg,bell_pair::BellPair,::Union{ComputationQubit,TrapQubit},initialisation::Float64)
        max_damping!(qureg,bell_pair)
        pauliX(qureg,bell_pair)
        hadamard(qureg,bell_pair)
        controlledNot(qureg,bell_pair)
        rotateZ(qureg,bell_pair,-initialisation)
        hadamard(qureg,bell_pair)
        outcome = measure(qureg,bell_pair)
        get_state_prep_angle(outcome,initialisation)
    end  


    function entangle_tranfer_get_prep_state!(qureg::Qureg,bell_pair::BellPair,::DummyQubit,initialisation::Union{Float64,Int})
        max_damping!(qureg,bell_pair)
        initialisation == 0 ? nothing : pauliX(qureg,bell_pair)
        controlledNot(qureg,bell_pair)
        outcome = measure(qureg,bell_pair)
        get_state_prep_angle(outcome,initialisation)    
    end  


// # end


##################################################################
# Teleportation function: teleport!
##################################################################
// # functions
    # For MBQC only - no initial angles, only plus state
    function teleport!(ne::AbstractNoNetworkEmulation) 
        qureg = get_quantum_backend(ne)
        num_qubits = get_num_qubits(ne)
        qubit_indices = get_qubit_range_one_to_n(ne)
        qubit_types = [ComputationQubit() for i in qubit_indices]
        adapted_prep_angles = [0.0 for i in qubit_indices]
        [QuEST.hadamard(qureg,i) for i in Base.OneTo(num_qubits)]
        InitialisedServer(qureg,collect(qubit_indices),qubit_types,adapted_prep_angles)
    end

    
    function teleport!(ne::AbstractImplicitNetworkEmulation) 
        qureg = get_quantum_backend(ne)
        num_qubits = get_num_qubits(ne)
        initialisations = get_basis_init_angles(ne)
        qubit_types = get_qubit_types(ne)
        
        server_indices = get_server_indices(ne)
        @assert all([server_indices[i] == i for i in Base.OneTo(num_qubits)]) "Qubit range must be 1..Num qubits."
        adapted_prep_angles = [0.0 for i in server_indices]
        for qubit_index in server_indices
            init_state!(qureg,qubit_types[qubit_index],qubit_index,initialisations[qubit_index]) 
        end
        
        InitialisedServer(qureg,collect(server_indices),qubit_types,adapted_prep_angles)
    end

    function teleport!(ne::AbstractBellPairExplicitNetwork) 
        qureg = get_quantum_backend(ne)
        bell_pairs = get_bell_pairs(ne)
        qubit_types = get_qubit_types(ne)
        initialisations = get_basis_init_angles(ne)
        new_basis_angles = entangle_tranfer_get_prep_state!.(Ref(qureg),bell_pairs,qubit_types,initialisations)
        server_indices = get_server_indices(ne)
        InitialisedServer(qureg,collect(server_indices),qubit_types,new_basis_angles)
    end



//  # end





// # Updated initialised angles
    function update_init_angles!(mg::MetaGraphs.MetaGraph{Int64, Float64},is::AbstractInitialisedServer,network_type::AbstractNoNetworkEmulation) 
        mg
    end
    function update_init_angles!(mg::MetaGraphs.MetaGraph{Int64, Float64},is::AbstractInitialisedServer,network_type::AbstractImplicitNetworkEmulation) 
        mg
    end
    function update_init_angles!(mg::MetaGraphs.MetaGraph{Int64, Float64},is::AbstractInitialisedServer,network_type::AbstractBellPairExplicitNetwork) 
        # Tests if qubit is a dummy qubit - if it is - insert current init_qubt
        # if it is not, inserts adapted_prep_angles
        qubit_types = get_qubit_types(is)
        angles = get_adapted_prep_angles(is)
        updated_angles = [
            qubit_types[x] != DummyQubit() ? angles[x] : get_prop(mg,x,:init_qubit) 
                    for x in eachindex(qubit_types)]
        [set_prop!(mg,i,:init_qubit,updated_angles[i]) for i in eachindex(updated_angles)]
        mg
    end

    function update_init_angles!(mg::MetaGraphs.MetaGraph{Int64, Float64},is::AbstractInitialisedServer)
        network_type = get_network_type(mg)
        update_init_angles!(mg,is,network_type)
    end
// # end






