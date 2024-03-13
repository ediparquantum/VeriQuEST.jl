##################################################################
# Filename  : input_output_mbqc.jl
# Author    : Jonathan Miller
# Date      : 2024-03-12
# Aim       : aim_script

#           :
##################################################################





struct Inputs <: AbstractInputs 
    indices::Union{Int,Tuple{Int},Vector{Int},Missing}
    values::Union{Int,Tuple{Int},Vector{Int},Missing}
    function Inputs()
        new(missing,missing)
    end
    function Inputs(indices,values)
        new(indices,values)
    end
end
struct Outputs <: AbstractOutputs 
    indices::Union{Int,Tuple{Int},Vector{Int}}
end
struct InputOutput <: AbstractInputOutputs
    inputs::AbstractInputs
    outputs::AbstractOutputs
    function InputOutput(inputs,outputs)
        new(inputs,outputs)
    end
    function InputOutput(outputs)
        new(Inputs(),outputs)
    end
end

function get_indices(inputs::AbstractInputs)
    inputs.indices
end

function get_values(inputs::AbstractInputs)
    inputs.values
end

function get_indices(outputs::AbstractOutputs)
    outputs.indices
end

function get_inputs(inputs::AbstractInputOutputs)
    inputs.inputs
end

function get_outputs(outputs::AbstractInputOutputs)
    outputs.outputs
end
