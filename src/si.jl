mutable struct SpecificInfo <: InfoDist
    joint::Matrix{Int}
    m1::Vector{Int}
    m2::Vector{Int}
    b1::Int
    b2::Int
    N::Int
    function SpecificInfo(b1::Int, b2::Int)
        if b1 < 1 || b2 < 1
            throw(ArgumentError("the support of each random variable must be at least 2"))
        end
        new(zeros(Int, b1, b2), zeros(Int, b1), zeros(Int, b2), b1, b2, 0)
    end
end

function SpecificInfo(xs::AbstractVector{Int}, ys::AbstractVector{Int})
    if isempty(xs) || isempty(ys)
        throw(ArgumentError("arguments must not be empty"))
    end
    xmin, xmax = extrema(xs)
    ymin, ymax = extrema(ys)
    if xmin < 1 || ymin < 1
        throw(ArgumentError("observations must be positive, nonzero"))
    end
    observe!(SpecificInfo(max(2, xmax), max(2, ymax)), xs, ys)
end

function observe!(dist::SpecificInfo, xs::AbstractVector{Int}, ys::AbstractVector{Int})
    if length(xs) != length(ys)
        throw(ArgumentError("arguments must have the same length"))
    end
    dist.N += length(xs)
    for i in eachindex(xs)
        dist.joint[xs[i], ys[i]] += 1
        dist.m1[xs[i]] += 1
        dist.m2[ys[i]] += 1
    end
    dist
end

function estimate(dist::SpecificInfo)
    si = zeros(dist.b1)
    N = dist.N
    for x1 in eachindex(dist.m1)
        n1 = dist.m1[x1]
        for x2 in eachindex(dist.m2)
            if !iszero(dist.joint[x1,x2])
                j, n2 = dist.joint[x1,x2], dist.m2[x2]
                si[x1] += j * log2((N * j) / (n1 * n2))
            end
        end
        si[x1] /= n1
    end
    si
end

@inline function clear!(dist::SpecificInfo)
    dist.joint[:] .= 0
    dist.m1[:] .= 0
    dist.m2[:] .= 0
    dist.N = 0
    dist
end

function specificinfo!(si::SpecificInfo, stimulus::AbstractVector{Int},
                       responses::AbstractMatrix{Int})
    specificinfo!(si, stimulus, box(responses))
end

function specificinfo!(si::SpecificInfo, stimulus::AbstractVector{Int},
                       responses::AbstractMatrix{Int}, subset::AbstractVector{Int})
    specificinfo!(si, stimulus, @view responses[subset, :])
end

function specificinfo!(si::SpecificInfo, stimulus::AbstractVector{Int},
                       responses::AbstractVector{Int})
    estimate(observe!(dist, stimulus, responses))
end

function specificinfo(stimulus::AbstractVector{Int}, responses::AbstractMatrix{Int})
    specificinfo(stimulus, box(responses))
end

function specificinfo(stimulus::AbstractVector{Int}, responses::AbstractMatrix{Int},
                      subset::AbstractVector{Int})
    specificinfo(stimulus, @view responses[subset, :])
end

function specificinfo(stimulus::AbstractVector{Int}, responses::AbstractVector{Int})
    estimate(SpecificInfo(stimulus, responses))
end
