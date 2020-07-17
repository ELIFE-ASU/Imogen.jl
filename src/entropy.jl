mutable struct Entropy <: InfoDist
    data::Vector{Int}
    b::Int
    N::Int
    Entropy(b) = new(zeros(Int, b), b, 0)
end

function observe!(dist::Entropy, xs::AbstractVector{Int})
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

estimate(d::Entropy) = entropy(dist.data, dist.N)

entropy!(d::Entropy, xs::AbstractVector{Int}) = estimate(observe!(d, xs))

entropy(xs::AbstractVector{Int}) = entropy!(Entropy(maximum(xs)), xs)

Base.length(dist::Entropy) = dist.b

Base.getindex(dist::Entropy, idx...) = getindex(dist.data, idx...)
