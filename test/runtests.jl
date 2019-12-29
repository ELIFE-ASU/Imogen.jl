using Eolas, Test

import Eolas: genvertices, toposort!, isbelow

near(a::Float64, b::Float64; ϵ=1e-10) = abs(a - b) < ϵ

include("lattice.jl")
include("williamsbeer.jl")
