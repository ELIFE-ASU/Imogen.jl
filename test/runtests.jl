using Imogen, Test

import Imogen: genvertices, toposort!, isbelow

near(a::Float64, b::Float64; ϵ=1e-10) = abs(a - b) < ϵ

include("mi.jl")
include("ai.jl")
include("te.jl")
include("lattice.jl")
include("williamsbeer.jl")
