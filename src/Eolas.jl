module Eolas

export AbstractVertex, AbstractUnnamedVertex, AbstractNamedVertex, id, name, payload, above, below
export UnnamedVertex, Vertex, clone
export Hasse, top, bottom, vertices, zero!, prune, graphviz
export WilliamsBeer, pid, pid!

include("util.jl")
include("lattice.jl")
include("info.jl")
include("pid.jl")
include("williamsbeer.jl")

end
