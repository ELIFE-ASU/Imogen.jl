module Eolas

export AbstractVertex, AbstractUnnamedVertex, AbstractNamedVertex, id, name, payload, above, below
export UnnamedVertex, Vertex
export Hasse, top, bottom, vertices
export WilliamsBeer, pid

include("lattice.jl")
include("info.jl")
include("williamsbeer.jl")

end
