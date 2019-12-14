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

"""
    isbelow(a, b)

Determine whether or not `a` is below `b`.
"""
function isbelow(xs::Name, ys::Name)
    is_below = true
    for y in ys
        is_valid = false
        for x in xs
            if x == x & y
                is_valid = true
                break
            end
        end
        if !is_valid
            is_below = false
            break
        end
    end
    is_below
end
isbelow(a::AbstractVertex, b::AbstractVertex) = isbelow(name(a), name(b))
