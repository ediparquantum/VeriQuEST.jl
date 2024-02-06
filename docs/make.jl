using RobustBlindVerification
using Documenter

DocMeta.setdocmeta!(RobustBlindVerification, :DocTestSetup, :(using RobustBlindVerification); recursive=true)
#=
makedocs(;
    modules=[RobustBlindVerification],
    authors="Jonathan Miller",
    repo="https://github.com/fieldofnodes/RobustBlindVerification.jl/blob/{commit}{path}#{line}",
    sitename="RobustBlindVerification.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://fieldofnodes.github.io/RobustBlindVerification.jl",
        edit_link="main",

    ),
    pages=[
        "Home" => "index.md",
    ],
)
=#
makedocs(
    modules  = [RobustBlindVerification],
    sitename = "RobustBlindVerification",
    warnonly = true,
    format   = Documenter.HTML(
        size_threshold = nothing,
        prettyurls = get(ENV, "CI", nothing) == "true",
        assets=String[],
        collapselevel = 1,
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/fieldofnodes/RobustBlindVerification.jl",
    devbranch="gh-pages")

    #=
repo="github.com/fieldofnodes/RobustBlindVerification.jl"
withenv("GITHUB_REPOSITORY" => repo) do
    deploydocs(
      repo = repo,
      target = "build",
      push_preview = true,
      forcepush = true,
    )
end=#