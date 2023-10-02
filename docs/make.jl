using QuESTMbqcBqpVerification
using Documenter

DocMeta.setdocmeta!(QuESTMbqcBqpVerification, :DocTestSetup, :(using QuESTMbqcBqpVerification); recursive=true)

makedocs(;
    modules=[QuESTMbqcBqpVerification],
    authors="Jonathan Miller",
    repo="https://github.com/fieldofnodes/QuESTMbqcBqpVerification.jl/blob/{commit}{path}#{line}",
    sitename="QuESTMbqcBqpVerification.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://fieldofnodes.github.io/QuESTMbqcBqpVerification.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/fieldofnodes/QuESTMbqcBqpVerification.jl",
    devbranch="main",
)
