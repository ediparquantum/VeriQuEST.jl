using RobustBlindVerification
using Documenter

DocMeta.setdocmeta!(RobustBlindVerification, :DocTestSetup, :(using RobustBlindVerification); recursive=true)

makedocs(;
    modules=[RobustBlindVerification],
    authors="Jonathan Miller",
    repo="https://github.com/fieldofnodes/RobustBlindVerification.jl/blob/{commit}{path}#{line}",
    sitename="RobustBlindVerification.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://fieldofnodes.github.io/RobustBlindVerification.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/fieldofnodes/RobustBlindVerification.jl",
    devbranch="main",
)
