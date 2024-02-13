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
        assets=String[],
        size_threshold = 1_000_000,
    ),
    pages=[
        "Introduction to RobustBlindVerification.jl" => "index.md",
        "User Guide" => [
            "Getting Started" => "user/getting_started.md",
            "Interface with QuEST" => "user/interface_with_quest.md",
            "Circuit Base Quantum Computing" => "user/circuit_base_quantum_computing.md",
            "Measurement Based Quantum Computing" => "user/measurement_based_quantum_computing.md",
            "Universal Blind Quantum Computing" => "user/blind_quantum_computing.md",
            "Robust Blind Verification" => "user/robust_blind_verification.md",
            "Quantum Noise" => "user/quantum_noise.md",
        ],
        "References" => [
            "QuEST functions" => "references/quest.md",
            "Noise functions" => "references/noise_functions.md",
            "Client functions" => "references/client.md",
            "Server functions" => "references/server.md",
            "Client-Server functions" => "references/client_server.md",
            "Malicious server functions" => "references/malicious_server.md",
            "Noisy server functions" => "references/noisy_server.md",
            "Verification functions" => "references/verification.md",
            "General or helper functions" => "references/general.md"
        ]
    ],
)

deploydocs(;
    repo="github.com/fieldofnodes/RobustBlindVerification.jl", 
    devbranch = "main",
    devurl="dev",
    target = "build",
    branch = "gh-pages",
    versions = ["stable" => "v^", "v#.#" ]
)



