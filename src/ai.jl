mutable struct ActiveInfo{D} <: InfoDist
    joint::Matrix{Int}
    future::Vector{Int}
    history::Vector{Int}
    B::Int
    bs::NTuple{D,Int}
    k::Int
    N::Int
    function ActiveInfo(bs::NTuple{D, <:Integer}; k::Integer=1) where D
        if any(b -> b < 2, bs)
            throw(ArgumentError("the support of the future must be at least 2"))
        elseif k < 1
            throw(ArgumentError("history length must be at least 1"))
        end
        B = prod(bs)
        new{D}(zeros(Int, B, B^k), zeros(Int, B), zeros(Int, B^k), B, bs, k, 0)
    end
end

ActiveInfo(b::Integer; kwargs...) = ActiveInfo((b,); kwargs...)

function ActiveInfo(xs::AbstractArray{Int,3}; k::Int=1)
    if k < 1
        throw(ArgumentError("history length must be at least 1"))
    elseif length(xs) ≤ k
        throw(ArgumentError("first argument's length must be greater than the history length"))
    end
    xmax = max.(2, maximum(xs; dims=(2,3)))
    observe!(ActiveInfo(tuple(xmax...); k), xs)
end

function ActiveInfo(xs::AbstractArray{Int,2}; k::Int=1)
    if k < 1
        throw(ArgumentError("history length must be at least 1"))
    elseif length(xs) ≤ k
        throw(ArgumentError("first argument's length must be greater than the history length"))
    end
    xmax = max.(2, maximum(xs; dims=2))
    observe!(ActiveInfo(tuple(xmax...); k), xs)
end

function ActiveInfo(xs::AbstractArray{Int,1}; k::Int=1)
    if k < 1
        throw(ArgumentError("history length must be at least 1"))
    elseif length(xs) ≤ k
        throw(ArgumentError("first argument's length must be greater than the history length"))
    end
    xmax = max(2, maximum(xs))
    observe!(ActiveInfo(xmax; k), xs)
end

function estimate(dist::ActiveInfo)
    entropy(dist.future, dist.N) + entropy(dist.history, dist.N) - entropy(dist.joint, dist.N)
end

function observe!(dist::ActiveInfo, xs::AbstractArray{Int,3})
    @views for i in 1:size(xs, 3)
        observe!(dist, xs[:,:,i])
    end
    dist
end

function observe!(dist::ActiveInfo, xs::AbstractArray{Int,2})
    if size(xs, 2) ≤ dist.k
        throw(ArgumentError("data's length must be greater than the history length"))
    end
    dist.N += size(xs, 2) - dist.k
    history, q = 0, 1
    @views for t in 1:dist.k
        q *= dist.B
        history = dist.B * history + index(xs[:,t], dist.bs) - 1
    end
    @views for t in dist.k+1:size(xs, 2)
        x = index(xs[:,t], dist.bs)
        dist.future[x] += 1
        dist.history[history + 1] += 1
        dist.joint[x, history + 1] += 1
        history = dist.B * history - q * (index(xs[:,t-dist.k], dist.bs) - 1) + x - 1
    end
    dist
end

function observe!(dist::ActiveInfo, xs::AbstractArray{Int,1})
    if length(xs) ≤ dist.k
        throw(ArgumentError("data's length must be greater than the history length"))
    end
    dist.N += length(xs) - dist.k
    history, q = 0, 1
    @views for t in 1:dist.k
        q *= dist.bs[1]
        history = dist.bs[1] * history + xs[t] - 1
    end
    @views for t in dist.k+1:length(xs)
        dist.future[xs[t]] += 1
        dist.history[history + 1] += 1
        dist.joint[xs[t], history + 1] += 1
        history = dist.bs[1] * history - q * (xs[t - dist.k] - 1) + xs[t] - 1
    end
    dist
end

@inline function clear!(dist::ActiveInfo)
    dist.joint[:] .= 0
    dist.future[:] .= 0
    dist.history[:] .= 0
    dist.N = 0
    dist
end

function activeinfo!(dist::ActiveInfo, xs::AbstractArray{Int})
    estimate(observe!(dist, xs))
end

activeinfo(xs::AbstractArray{Int}; kwargs...) = estimate(ActiveInfo(xs; kwargs...))

function activeinfo(::Type{Kraskov1}, xs::AbstractMatrix{Float64};
                    k::Int=1, τ::Int=1, nn::Int=1, metric::Metric=Chebyshev())
    hs = history(xs, k, τ, 1)
    fs = @view xs[:, end-size(hs, 2)+1:end]
    mutualinfo(Kraskov1, fs, hs; nn=nn, metric=metric)
end

function activeinfo(::Type{Kraskov1}, xs::AbstractMatrix{Float64},
                    cond::AbstractMatrix{Float64}, conds::AbstractMatrix{Float64}...;
                    k::Int=1, τ::Int=1, nn::Int=1, metric::Metric=Chebyshev())
    hs = history(xs, k, τ, 1)
    N = size(hs, 2)
    fs = @view xs[:, end-N+1:end]
    condview = @view cond[:, end-N:end-1]
    condviews = [@view c[:, end-N:end-1] for c in conds]
    mutualinfo(Kraskov1, fs, hs, condview, condviews...; nn=nn, metric=metric)
end

function activeinfo(::Type{Kraskov}, xs::AbstractMatrix{Float64}, conds::AbstractMatrix{Float64}...; kwargs...)
    activeinfo(Kraskov1, xs, conds...; kwargs...)
end

function activeinfo(xs::AbstractMatrix{Float64}, conds::AbstractMatrix{Float64}...; kwargs...)
    activeinfo(Kraskov1, xs, conds...; kwargs...)
end

function activeinfo(xs::AbstractVector{Float64}, cond::AbstractVector{Float64}...; kwargs...)
    conds = map(c -> reshape(c, 1, length(c)), cond)
    activeinfo(reshape(xs, 1, length(xs)), conds...; kwargs...)
end
