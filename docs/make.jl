using Documenter
using Imogen

DocMeta.setdocmeta!(Imogen, :DocTestSetup, :(using Imogen); recursive=true)
makedocs(
    sitename = "Imogen",
    format = Documenter.HTML(),
    modules = [Imogen],
    authors = "Douglas G. Moore",
    pages = Any[
        "Home" => "index.md",
    ]
)

deploydocs(
    repo = "github.com/dglmoore/Imogen.jl.git"
)
