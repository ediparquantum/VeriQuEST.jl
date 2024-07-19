using VeriQuEST
using Documenter

DocMeta.setdocmeta!(VeriQuEST, :DocTestSetup, :(using VeriQuEST); recursive=true)

makedocs(;
    modules=[VeriQuEST],
    authors="Jonathan Miller",
    repo="https://github.com/fieldofnodes/VeriQuEST.jl/blob/{commit}{path}#{line}",
    sitename="VeriQuEST.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://fieldofnodes.github.io/VeriQuEST.jl",
        assets=String[],
        size_threshold = 1_000_000,
    ),
    pages=[
        "Introduction to VeriQuEST.jl" => "index.md",
        #"User Guide" => [
        #   "Getting Started" => "user/getting_started.md",
        #    "Notes on Noise" => "user/quantum_noise.md",
        #   "Grover example" => "user/grover_example.md",
        #],
        "References" => 
            ["API" => "references/api.md"]
    ],
)

deploydocs(;
    repo="github.com/fieldofnodes/VeriQuEST.jl", 
    devbranch = "main",
    devurl="dev",
    target = "build",
    branch = "gh-pages",
    versions = ["stable" => "v^", "v#.#" ]
)



