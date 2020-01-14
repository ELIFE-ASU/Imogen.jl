mutable struct MIDist <: InfoDist
    joint::Matrix{Int}
    m1::Vector{Int}
    m2::Vector{Int}
    b1::Int
    b2::Int
    N::Int
    function MIDist(b1::Integer, b2::Integer)
        if b1 < 2 || b2 < 2
            throw(ArgumentError("the support of each random variable must be at least 2"))
        end
        new(zeros(Int, b1, b2), zeros(Int, b1), zeros(Int, b2), b1, b2, 0)
    end
end

function MIDist(xs::AbstractVector{Int}, ys::AbstractVector{Int})
    xmin, xmax = extrema(xs)
    ymin, ymax = extrema(ys)
    if xmin < 1 || ymin < 1
        throw(ArgumentError("observations must be positive, nonzero"))
    end
    observe!(MIDist(max(2, xmax), max(2, ymax)), xs, ys)
end

function estimate(dist::MIDist)
    entropy(dist.m1, dist.N) + entropy(dist.m2, dist.N) - entropy(dist.joint, dist.N)
end

function observe!(dist::MIDist, xs::AbstractVector{Int}, ys::AbstractVector{Int})
    dist.N += length(xs)
    for i in eachindex(xs)
        x, y = xs[i], ys[i]
        dist.m1[x] += 1
        dist.m2[y] += 1
        dist.joint[x, y] += 1
    end
    dist
end

@inline function clear!(dist::MIDist)
    dist.joint[:] .= 0
    dist.m1[:] .= 0
    dist.m2[:] .= 0
    dist.N = 0
    dist
end

function mutualinfo!(dist::MIDist, xs::AbstractVector{Int}, ys::AbstractVector{Int})
    estimate(observe!(dist, xs, ys))
end

mutualinfo(xs::AbstractVector{Int}, ys::AbstractVector{Int}) = estimate(MIDist(xs, ys))
