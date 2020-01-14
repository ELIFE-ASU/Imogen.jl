module Eolas

using DataFrames

export AbstractVertex, AbstractUnnamedVertex, AbstractNamedVertex, id, name, payload, above, below
export UnnamedVertex, Vertex, clone
export Hasse, top, bottom, vertices, zero!, prune, graphviz
export WilliamsBeer, pid, pid!
export EmpericalDist
export MIDist, entropy, mutualinfo!, mutualinfo
export TEDist, entropy, transferentropy!, transferentropy

include("util.jl")
include("lattice.jl")
include("info.jl")
include("mi.jl")
include("si.jl")
include("te.jl")
include("pid.jl")
include("williamsbeer.jl")

end
