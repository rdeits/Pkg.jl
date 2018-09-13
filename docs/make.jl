# This file is a part of Julia. License is MIT: https://julialang.org/license

using Documenter
using Pkg

makedocs(
    modules = [Pkg],
    format = :html,
    sitename = "Pkg.jl",
    pages = Any[
        "index.md",
        "getting-started.md",
        "glossary.md",
        "managing-packages.md",
        "creating-packages.md",
        "compatibility.md",
        "registries.md",
        "faq.md",
        "api.md"
    ]
)

deploydocs(
    repo = "github.com/JuliaLang/Pkg.jl",
    target = "build",
    julia = "nightly",
    deps = nothing,
    make = nothing,
)
