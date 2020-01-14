mutable struct MIDist <: InfoDist
    joint::Matrix{Int}
    m1::Vector{Int}
    m2::Vector{Int}
    N::Int
    MIDist() = new(zeros(Int, 2, 2), zeros(Int, 2), zeros(Int, 2), 0)
end

MIDist(xs::AbstractVector{Int}, ys::AbstractVector{Int}) = observe!(MIDist(), xs, ys)

function estimate(dist::MIDist)
    mi = 0.0
    for i in 1:2, j in 1:2
        p = dist.joint[i,j]
        if !iszero(p)
            mi += p * log2(p / (dist.m1[i] * dist.m2[j]))
        end
    end
    log2(dist.N) + mi/dist.N
end

function observe!(dist::MIDist, xs::AbstractVector{Int}, ys::AbstractVector{Int})
    dist.N += length(xs)
    @inbounds for i in eachindex(xs)
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

mutualinfo(xs::AbstractVector{Int}, ys::AbstractVector{Int}) = mutualinfo!(MIDist(), xs, ys)
