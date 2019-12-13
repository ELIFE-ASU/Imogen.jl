using Documenter
using Eolas

DocMeta.setdocmeta!(Eolas, :DocTestSetup, :(using Eolas); recursive=true)
makedocs(
    sitename = "Eolas",
    format = Documenter.HTML(),
    modules = [Eolas],
    authors = "Douglas G. Moore",
    pages = Any[
        "Home" => "index.md",
    ]
)

deploydocs(
    repo = "github.com/dglmoore/Eolas.jl.git"
)
