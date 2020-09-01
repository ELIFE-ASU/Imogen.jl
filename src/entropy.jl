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
