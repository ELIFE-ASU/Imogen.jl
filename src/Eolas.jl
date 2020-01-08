module Eolas

export AbstractVertex, AbstractUnnamedVertex, AbstractNamedVertex, id, name, payload, above, below
export UnnamedVertex, Vertex, clone
export Hasse, top, bottom, vertices, prune
export WilliamsBeer, pid

include("lattice.jl")
include("info.jl")
include("williamsbeer.jl")

end
