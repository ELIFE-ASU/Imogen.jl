module Eolas

using DataFrames

export InfoDist, observe!, clear!, estimate
export Dist, entropy!, entropy
export MIDist, mutualinfo!, mutualinfo
export TEDist, transferentropy!, transferentropy
export AbstractVertex, AbstractUnnamedVertex, AbstractNamedVertex, id, name, payload, above, below
export UnnamedVertex, Vertex, clone
export Hasse, top, bottom, vertices, zero!, prune, graphviz
export WilliamsBeer, pid, pid!

include("core.jl")

include("util.jl")

include("entropy.jl")

include("mi.jl")

include("si.jl")

include("te.jl")

include("lattice.jl")
include("pid.jl")
include("williamsbeer.jl")

end
