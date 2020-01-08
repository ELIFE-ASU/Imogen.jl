"""
    AbstractVertex{P}

A supertype for all vertex types with a payload of type `P`.
"""
abstract type AbstractVertex{P} end

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

Base.length(v::AbstractVertex) = length(id(v))

Base.eachindex(v::AbstractVertex) = eachindex(id(v))

Base.getindex(v::AbstractVertex, idx...) = getindex(id(v), idx...)

"""
    VertexID = Vector{Int}

A type alias for integer arrays used as ids of vertices.
"""
const VertexID = Vector{Int}

"""
    Vertex{P} <: AbstractVertex{P}

A standard vertex containing a `id`, `payload`, and arrays of vertices
`above` and `below` it.
"""
mutable struct Vertex{P, V <: AbstractVertex{P}} <: AbstractVertex{P}
    id::VertexID
    payload::P
    above::Vector{V}
    below::Vector{V}
end

"""
    Vertex(id, p)

Construct a `Vertex` with a given `id` and payload (`p`), with no vertices
above or below.
"""
Vertex(id::VertexID, p::P) where P = Vertex(id, p, Vertex{P}[], Vertex{P}[])

"""
    Vertex{P}(id)

Construct a `Vertex` with a given `id`, a "zeroed" payload of type `P` and no
vertices above or below.
"""
Vertex{P}(id::VertexID) where P = Vertex(id, zero(P))

Base.show(io::IO, v::Vertex{P,V}) where {P, V} = print(io, "Vertex(", v.id, ", ", v.payload, ")")

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
    genvertices(::Type{V}, n) where {V <: AbstractVertex}

Construct an array populated with all vertices of type `V` of `n`
elements.
"""
function genvertices(::Type{V}, n::Int64) where {V <: AbstractVertex}
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

function genvertices!(vs::AbstractVector{V}, i, m, c) where {V <: AbstractVertex}
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
    Hasse{P}

A Hasse diagram (lattice) with payload of type `P` on its vertices.
"""
mutable struct Hasse{P}
    top::Vertex{P}
    bottom::Vertex{P}
    vertices::Vector{Vertex{P}}
end

"""
Hasse{P}(n)

Construct a Hasse diagram of order `n` with zeroed payloads of type `P` on its
vertices.
"""
Hasse{P}(n::Int64) where P = Hasse(genvertices(Vertex{P}, n))

function Hasse(vs::AbstractVector{Vertex{P}}; sort::Bool=true) where P
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

    Hasse{P}(vs[end], vs[1], vs)
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
