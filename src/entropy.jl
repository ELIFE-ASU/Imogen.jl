mutable struct Dist <: EmpericalDist
    data::Vector{Int}
    b::Int
    N::Int
    Dist(b) = new(zeros(Int, b), b, 0)
end

function observe!(dist::Dist, xs::AbstractVector{Int})
    dist.N += length(xs)
    for i in eachindex(xs)
        dist.data[xs[i]] += 1
    end
    dist
end

function entropy(xs::AbstractArray{Int}, N::Int)
    h = N * log2(N)
    for i in eachindex(xs)
        n = xs[i]
        if !iszero(n)
            h -= n * log2(n)
        end
    end
    h / N
end

estimate(d::Dist) = entropy(dist.data, dist.N)

entropy!(d::Dist, xs::AbstractVector{Int}) = estimate(observe!(d, xs))

entropy(xs::AbstractVector{Int}) = entropy!(Dist(maximum(xs)), xs)

Base.length(dist) = dist.b

Base.getindex(dist, idx...) = getindex(dist.data, idx...)
