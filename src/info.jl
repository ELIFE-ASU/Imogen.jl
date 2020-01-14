mutable struct Dist
    data::Vector{Int}
    b::Int
    N::Int
    Dist(b) = new(zeros(Int, b), b, 0)
end

function accumulate!(dist::Dist, xs::AbstractVector{Int})
    dist.N += length(xs)
    for i in eachindex(xs)
        dist.data[xs[i]] += 1
    end
    dist
end

Base.length(dist) = dist.b

Base.getindex(dist, idx...) = getindex(dist.data, idx...)
