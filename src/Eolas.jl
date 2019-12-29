module Eolas

export AbstractVertex, name, payload, above, below, Vertex
export Hasse, top, bottom, vertices
export pid, WilliamsBeer

include("lattice.jl")
include("info.jl")
include("williamsbeer.jl")

end
