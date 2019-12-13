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
    name(v)

Get the name of a vertex.
"""
name(v::AbstractVertex) = v.name

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


"""
    Name = Vector{Int}

A type alias for integer arrays used as names of vertices.
"""
const Name = Vector{Int}

"""
    Vertex{P} <: AbstractVertex{P}

A standard vertex containing a `name`, `payload`, and arrays of vertices
`above` and `below` it.
"""
mutable struct Vertex{P, V <: AbstractVertex{P}} <: AbstractVertex{P}
    name::Name
    payload::P
    above::Vector{V}
    below::Vector{V}
end

"""
    Vertex(name, p)

Construct a `Vertex` with a given `name` and payload (`p`), with no vertices
above or below.
"""
Vertex(name::Name, p::P) where P = Vertex(name, p, Vertex{P}[], Vertex{P}[])

"""
    Vertex{P}(name)

Construct a `Vertex` with a given `name`, a "zeroed" payload of type `P` and no
vertices above or below.
"""
Vertex{P}(name::Name) where P = Vertex(name, zero(P))

Base.show(io::IO, v::Vertex{P,V}) where {P, V} = print(io, "Vertex(", v.name, ", ", v.payload, ")")
