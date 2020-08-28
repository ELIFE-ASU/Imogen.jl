mutable struct MutualInfo <: InfoDist
    joint::Matrix{Int}
    m1::Vector{Int}
    m2::Vector{Int}
    b1::Int
    b2::Int
    N::Int
    function MutualInfo(b1::Integer, b2::Integer)
        if b1 < 2 || b2 < 2
            throw(ArgumentError("the support of each random variable must be at least 2"))
        end
        new(zeros(Int, b1, b2), zeros(Int, b1), zeros(Int, b2), b1, b2, 0)
    end
end

function MutualInfo(xs::AbstractVector{Int}, ys::AbstractVector{Int})
    if isempty(xs) || isempty(ys)
        throw(ArgumentError("arguments must not be empty"))
    end
    xmin, xmax = extrema(xs)
    ymin, ymax = extrema(ys)
    if xmin < 1 || ymin < 1
        throw(ArgumentError("observations must be positive, nonzero"))
    end
    observe!(MutualInfo(max(2, xmax), max(2, ymax)), xs, ys)
end

function estimate(dist::MutualInfo)
    entropy(dist.m1, dist.N) + entropy(dist.m2, dist.N) - entropy(dist.joint, dist.N)
end

function observe!(dist::MutualInfo, xs::AbstractVector{Int}, ys::AbstractVector{Int})
    if length(xs) != length(ys)
        throw(ArgumentError("arguments must have the same length"))
    end
    dist.N += length(xs)
    for i in eachindex(xs)
        x, y = xs[i], ys[i]
        dist.m1[x] += 1
        dist.m2[y] += 1
        dist.joint[x, y] += 1
    end
    dist
end

@inline function clear!(dist::MutualInfo)
    dist.joint[:] .= 0
    dist.m1[:] .= 0
    dist.m2[:] .= 0
    dist.N = 0
    dist
end

function mutualinfo!(dist::MutualInfo, xs::AbstractVector{Int}, ys::AbstractVector{Int})
    estimate(observe!(dist, xs, ys))
end

mutualinfo(xs::AbstractVector{Int}, ys::AbstractVector{Int}) = estimate(MutualInfo(xs, ys))

function mutualinfo(::Type{Kraskov1}, xs::AbstractMatrix{Float64}, ys::AbstractMatrix{Float64};
                    nn::Int=1, metric::Metric=Chebyshev())
    data = [xs; ys]
    joint = BallTree(data, metric)
    m1 = BallTree(xs, metric)
    m2 = BallTree(ys, metric)
    mi = zero(Float64)
    N = size(data, 2)

    δs = prevfloat.(last.(last(knn(joint, data, nn + 1, true))))
    @inbounds for i in 1:N
        nx = length(inrange(m1, xs[:, i], δs[i]))
        ny = length(inrange(m2, ys[:, i], δs[i]))
        mi += digamma(nx) + digamma(ny)
    end
    digamma(nn) - (mi/N) + digamma(N)
end

function mutualinfo(::Type{Kraskov1}, xs::AbstractMatrix{Float64}, ys::AbstractMatrix{Float64},
                    cond::AbstractMatrix{Float64}, conds::AbstractMatrix{Float64}...;
                    nn::Int=1, metric::Metric=Chebyshev())
    data = [xs; ys; cond; conds...]
    var1 = [xs; cond; conds...]
    var2 = [ys; cond; conds...]
    varcond = [cond; conds...]

    joint = BallTree(data, metric)
    m1 = BallTree(var1, metric)
    m2 = BallTree(var2, metric)
    mcond = BallTree(varcond, metric)

    mi = zero(Float64)
    N = size(data, 2)

    δs = prevfloat.(last.(last(knn(joint, data, nn + 1, true))))
    @inbounds for i in 1:N
        n1 = length(inrange(m1, var1[:, i], δs[i]))
        n2 = length(inrange(m2, var2[:, i], δs[i]))
        ncond = length(inrange(mcond, varcond[:, i], δs[i]))
        mi += digamma(ncond) - digamma(n1) - digamma(n2)
    end
    digamma(nn) + (mi/N)
end

function mutualinfo(::Type{Kraskov}, xs::AbstractMatrix{Float64}, ys::AbstractMatrix{Float64},
                    cond::AbstractMatrix{Float64}...; kwargs...)
    mutualinfo(Kraskov1, xs, ys, cond...; kwargs...)
end

function mutualinfo(xs::AbstractMatrix{Float64}, ys::AbstractMatrix{Float64},
                    cond::AbstractMatrix{Float64}...; kwargs...)
    mutualinfo(Kraskov1, xs, ys, cond...; kwargs...)
end

function mutualinfo(xs::AbstractVector{Float64}, ys::AbstractVector{Float64},
                    cond::AbstractVector{Float64}...; kwargs...)
    conds = map(c -> reshape(c, 1, length(c)), cond)
    mutualinfo(reshape(xs, 1, length(xs)), reshape(ys, 1, length(ys)), conds...; kwargs...)
end
