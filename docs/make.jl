using Seahawk
using Documenter

makedocs(;
    modules=[Seahawk],
    authors="Ole Kröger <o.kroeger@opensourc.es> and contributors",
    repo="https://github.com/Wikunia/Seahawk.jl/blob/{commit}{path}#L{line}",
    sitename="Seahawk.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://Wikunia.github.io/Seahawk.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/Wikunia/Seahawk.jl",
)
