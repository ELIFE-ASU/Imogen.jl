mutable struct Entropy{D} <: InfoDist
    data::Array{Int, D}
    bs::NTuple{D, Int}
    N::Int
    function Entropy(b::Int, bs::Int...)
        if b ≤ zero(b) || any(b -> b ≤ zero(b), bs)
            throw(ArgumentError("all bases must be greater than zero"))
        end
        new{length(bs) + 1}(zeros(Int, b, bs...), tuple(b, bs...), 0)
    end
end

function Entropy(xs::AbstractMatrix{Int})
    iszero(length(xs)) && throw(ArgumentError("no observations provided"))
    any(b -> b < 1, xs) && throw(ArgumentError("observations must be 1 or greater"))

    dist = Entropy(maximum(xs; dims=2)...)
    observe!(dist, xs)
end
Entropy(xs::AbstractVector{Int}) = Entropy(reshape(xs, 1, length(xs)))

function observe!(dist::Entropy, xs::AbstractMatrix{Int})
    dist.N += size(xs, 2)
    for i in 1:size(xs, 2)
        dist.data[xs[:,i]...] += 1
    end
    dist
end
observe!(dist::Entropy, xs::AbstractVector{Int}) = observe!(dist, reshape(xs, 1, length(xs)))

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

estimate(dist::Entropy) = entropy(dist.data, dist.N)

entropy!(dist::Entropy, xs::AbstractMatrix{Int}) = estimate(observe!(dist, xs))
entropy!(dist::Entropy, xs::AbstractVector{Int}) = estimate(dist, reshape(xs, 1, length(xs)))

entropy(xs::AbstractArray{Int}) = estimate(Entropy(xs))

function clear!(dist::Entropy)
    fill!(dist.data, 0)
    dist.N = 0
end

Base.length(dist::Entropy) = prod(size(dist))

Base.size(dist::Entropy) = dist.bs

Base.getindex(dist::Entropy, idx...) = getindex(dist.data, idx...)

function entropy(::Type{Kozachenko}, xs::AbstractMatrix{Float64}; metric::Metric=Euclidean())
    D, T = size(xs)
    δ = minimumdistances(xs; metric=metric)
    D*(mean(log.(δ)) + log(2.0)) + sdterm(D) + eulermascheroni(T)
    D * (mean(log.(δ)) + log(2.0)) + sdterm(D) + eulermascheroni(T)
end

eulermascheroni(x) = (x < zero(x)) ? zero(Float64) : digamma(x) - digamma(1)

function sdterm(dim::Int)
    c = (π / 4.0)^(dim / 2)
    if iseven(dim)
        log(c) - sum(log.(2:(dim ÷ 2)))
    else
        c = (c * 2.0^((dim + 1) / 2.)) / sqrt(π)
        log(c) - sum(log.(3:2:dim))
    end
end

function minimumdistances(xs; metric::Metric=Euclidean())
    b = BallTree(xs)
    _, δ = knn(b, xs, 2)
    first.(δ)
end

entropy(xs::AbstractMatrix{Float64}; kwargs...) = entropy(Kozachenko, xs; kwargs...)

entropy(xs::AbstractVector{Float64}; kwargs...) = entropy(reshape(xs, 1, length(xs)))
