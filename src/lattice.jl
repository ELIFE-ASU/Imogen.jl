"""
    AbstractVertex{P}

A supertype for all vertex types with a payload of type `P`.
"""
abstract type AbstractVertex{P} end

abstract type AbstractUnnamedVertex{P} <: AbstractVertex{P} end

abstract type AbstractNamedVertex{N,P} <: AbstractVertex{P} end

"""
    payload(v)

Get a vertex's payload
"""
payload(v::AbstractVertex) = v.payload

"""
    id(v)

Get the id of a vertex.
"""
id(v::AbstractVertex) = v.id

"""
    above(v)

Get an array of all vertices above `v`.
"""
above(v::AbstractVertex) = v.above

"""
    below(v)

Get an array of all vertices below `v`.
"""
below(v::AbstractVertex) = v.below

name(v::AbstractNamedVertex) = v.name

Base.length(v::AbstractVertex) = length(id(v))

Base.eachindex(v::AbstractVertex) = eachindex(id(v))

Base.getindex(v::AbstractVertex, idx...) = getindex(id(v), idx...)

"""
    VertexID = Vector{Int}

A type alias for integer arrays used as ids of vertices.
"""
const VertexID = Vector{Int}

"""
    UnnamedVertex{P} <: AbstractVertex{P}

A standard vertex containing a `id`, `payload`, and arrays of vertices
`above` and `below` it.
"""
mutable struct UnnamedVertex{P, V <: AbstractUnnamedVertex{P}} <: AbstractUnnamedVertex{P}
    id::VertexID
    payload::P
    above::Vector{V}
    below::Vector{V}
end

"""
    UnnamedVertex(id, p)

Construct a `Vertex` with a given `id` and payload (`p`), with no vertices
above or below.
"""
function UnnamedVertex(id::VertexID, p::P) where P
    UnnamedVertex(id, p, UnnamedVertex{P}[], UnnamedVertex{P}[])
end

"""
    UnnamedVertex{P}(id)

Construct a `Vertex` with a given `id`, a "zeroed" payload of type `P` and no
vertices above or below.
"""
UnnamedVertex{P}(id::VertexID) where P = UnnamedVertex(id, zero(P))

function Base.show(io::IO, v::UnnamedVertex)
    print(io, "UnnamedVertex(", v.id, ", ", v.payload, ")")
end

clone(v::UnnamedVertex) = UnnamedVertex(id(v), payload(v))

mutable struct Vertex{N, P, V <: AbstractNamedVertex{N,P}} <: AbstractNamedVertex{N,P}
    id::VertexID
    name::Vector{Vector{N}}
    payload::P
    above::Vector{V}
    below::Vector{V}
end

function Vertex(id::VertexID, name::AbstractVector{Vector{N}}, p::P) where {N,P}
    Vertex(id, name, p, Vertex{N,P}[], Vertex{N,P}[])
end

function Vertex{N,P}(id::VertexID, name::AbstractVector{Vector{N}}) where {N,P}
    Vertex(id, name, zero(P))
end

function Base.show(io::IO, v::Vertex)
    print(io, "Vertex(", v.name, ", ", v.payload, ")")
end

name(v::Vertex) = v.name

clone(v::Vertex) = Vertex(id(v), name(v), payload(v))

function Base.convert(::Type{UnnamedVertex{T}}, v::Vertex{N,T}) where {N,T}
    a = convert(Vector{UnnamedVertex{T}}, above(v))
    b = convert(Vector{UnnamedVertex{T}}, below(v))
    UnnamedVertex(id(v), payload(v), a, b)
end

"""
    isbelow(a, b)

Determine whether or not `a` is below `b`.
"""
@inline function isbelow(xs::VertexID, ys::VertexID)
    for i in eachindex(ys)
        is_valid = false
        for j in eachindex(xs)
            if xs[j] & ys[i] == xs[j]
                is_valid = true
                break
            end
        end
        if !is_valid
            return false
        end
    end
    true
end

isbelow(a::AbstractVertex, b::AbstractVertex) = isbelow(id(a), id(b))

"""
    genvertices(::Type{V}, n) where {V <: AbstractUnnamedVertex}
"""
function genvertices(::Type{V}, n::Int64) where {V <: AbstractUnnamedVertex}
    if n < 1
        throw(DomainError(n, "at least one node is required"))
    end
    vs = V[]
    m = (1 << n) - 1;
    for i in 1:m
        push!(vs, V([i]))
        genvertices!(vs, i + 1, m, [i])
    end
    vs
end

function genvertices!(vs::AbstractVector{V}, i, m, c) where {V <: AbstractUnnamedVertex}
    if i < m
        genvertices!(vs, i+1, m, c[:])
    end

    if i <= m
        z = 0
        for j in 1:length(c)
            z = i & c[j]
            if (z == i || z == c[j])
                return vs
            end
        end
        push!(c, i)
        push!(vs, V(c))
        genvertices!(vs, i+1, m, c[:])
    end

    vs
end

function extractname(nodenames::AbstractVector{N}, id::Int) where N
    name = N[]
    for i in eachindex(nodenames)
        if id & (1 << (i-1)) != 0
            push!(name, nodenames[i])
        end
    end
    name
end

extractname(nodenames::AbstractVector, id::VertexID) = map(i -> extractname(nodenames, i), id)

function genvertices(::Type{V}, names::AbstractVector{N}) where {N, V <: AbstractNamedVertex{N}}
    if isempty(names)
        throw(DomainError(n, "at least one node is required"))
    end
    n = length(names)
    vs = V[]
    m = (1 << n) - 1;
    for i in 1:m
        id = [i]
        push!(vs, V(id, extractname(names, id)))
        genvertices!(vs, names, i + 1, m, [i])
    end
    vs
end

function genvertices!(vs::AbstractVector{V}, names, i, m, c) where {V <: AbstractNamedVertex}
    if i < m
        genvertices!(vs, names, i+1, m, c[:])
    end

    if i <= m
        z = 0
        for j in 1:length(c)
            z = i & c[j]
            if (z == i || z == c[j])
                return vs
            end
        end
        push!(c, i)
        push!(vs, V(c, extractname(names, c)))
        genvertices!(vs, names, i+1, m, c[:])
    end

    vs
end

"""
    toposort!(vs)

Topologically sort vertices according to the `isbelow` relation.
"""
function toposort!(vs::AbstractVector{V}) where {V <: AbstractVertex}
    n, u, v = length(vs), 1, 1
    while v < n - 1
        u = v
        for i in u:n
            is_bottom = true
            for j in u:n
                if i != j && isbelow(vs[j], vs[i])
                    is_bottom = false
                    break
                end
            end
            if is_bottom
                vs[v], vs[i] = vs[i], vs[v]
                v += 1
            end
        end
    end
    vs
end

"""
    Hasse{V}

A Hasse diagram (lattice) with vertices of type `V`
"""
mutable struct Hasse{V <: AbstractVertex}
    top::V
    bottom::V
    vertices::Vector{V}
end

Hasse(::Type{P}, n::Int64) where P = Hasse(genvertices(UnnamedVertex{P}, n))

Hasse(::Type{P}, names::AbstractVector{N}) where {N,P} = Hasse(genvertices(Vertex{N,P}, names))

function Hasse(vs::AbstractVector{V}; sort::Bool=true) where {V <: AbstractVertex}
    if isempty(vs)
        throw(ArgumentError("vertex list is empty"))
    end

    if sort
        toposort!(vs)
    end

    for i in 1:length(vs)
        for j in i+1:length(vs)
            if isbelow(vs[i], vs[j])
                stop = false
                for v in above(vs[i])
                    if isbelow(v, vs[j])
                        stop = true
                        break
                    end
                end
                if stop
                    break
                else
                    push!(above(vs[i]), vs[j])
                    push!(below(vs[j]), vs[i])
                end
            end
        end
    end

    Hasse(vs[end], vs[1], vs)
end

"""
    top(h)

Get the top vertex of the Hasse diagram `h`.
"""
top(h::Hasse) = h.top

"""
    bottom(h)

Get the bottom vertex of the Hasse diagram `h`.
"""
bottom(h::Hasse) = h.bottom

"""
    vertices(h)

Get the array of vertices of the Hasse diagram `h`.
"""
vertices(h::Hasse) = h.vertices

Base.length(h::Hasse) = length(vertices(h))

Base.eachindex(h::Hasse) = eachindex(vertices(h))

Base.getindex(h::Hasse, idx...) = getindex(vertices(h), idx...)

"""
    edgelist(h)

Get the array of edges — pairs of vertex ids — of the Hasse diagram `h`.
"""
function edgelist(h::Hasse)
    edges = NTuple{2, VertexID}[]
    vs = vertices(h)
    for v in vs, w in v.above
        push!(edges, (id(v), id(w)))
    end
    edges
end

function prune(f::Function, h::Hasse)
    vs = clone.(filter(f, vertices(h)))
    if isempty(vs)
        throw(ErrorException("pruned diagram has no vertices"))
    end
    Hasse(vs)
end
prune(h::Hasse) = prune(!iszero ∘ payload, h)
