mutable struct TransferEntropy{D,E} <: InfoDist
    states::Vector{Int}
    histories::Vector{Int}
    sources::Vector{Int}
    predicates::Vector{Int}
    bs::NTuple{D,Int}
    bt::NTuple{E,Int}
    k::Int
    Bs::Int
    Bt::Int
    q::Int
    N::Int

    function TransferEntropy(bs::NTuple{D, <:Integer}, bt::NTuple{E, <:Integer}; k::Int=1) where {D,E}
        if D == 0 || E == 0
            throw(MethodError(TransferEntropy, (bs, ts, kwargs...)))
        end
        if any(b -> b < 2, bs) || any(b -> b < 2, bt)
            throw(ArgumentError("the support of each random variable must be at least 2"))
        end
        if k < 1
            throw(ArgumentError("history length must be at least 1"))
        end
        Bs, Bt = prod(bs), prod(bt)
        q = Bt^k
        states = zeros(Int, Bs*Bt*q)
        histories = zeros(Int, q)
        sources = zeros(Int, Bt*q)
        predicates = zeros(Int, Bt*q)
        new{D,E}(states, histories, sources, predicates, bs, bt, k, Bs, Bt, q, 0)
    end
end
TransferEntropy(bs::Integer, bt::Integer; kwargs...) = TransferEntropy((bs,), (bt,); kwargs...)
TransferEntropy(bs::Integer, bt::NTuple; kwargs...) = TransferEntropy((bs,), bt; kwargs...)
TransferEntropy(bs::NTuple, bt::Integer; kwargs...) = TransferEntropy(bs, (bt,); kwargs...)

function TransferEntropy(source::AbstractArray{Int,3}, target::AbstractArray{Int,3}; k::Int=1)
    if isempty(source) || isempty(target)
        throw(ArgumentError("arguments must not be empty"))
    end
    smax = max.(2, maximum(source, dims=(2,3)))
    tmax = max.(2, maximum(target, dims=(2,3)))
    observe!(TransferEntropy(tuple(smax...), tuple(tmax...); k), source, target)
end

function TransferEntropy(source::AbstractArray{Int,2}, target::AbstractArray{Int,2}; k::Int=1)
    if isempty(source) || isempty(target)
        throw(ArgumentError("arguments must not be empty"))
    end
    smax = max.(2, maximum(source, dims=2))
    tmax = max.(2, maximum(target, dims=2))
    observe!(TransferEntropy(tuple(smax...), tuple(tmax...); k), source, target)
end

function TransferEntropy(source::AbstractArray{Int,1}, target::AbstractArray{Int,1}; k::Int=1)
    if isempty(source) || isempty(target)
        throw(ArgumentError("arguments must not be empty"))
    end
    smax = max(2, maximum(source))
    tmax = max(2, maximum(target))
    observe!(TransferEntropy(tuple(smax...), tuple(tmax...); k), source, target)
end

@inline function clear!(dist::TransferEntropy)
    dist.states[:] .= 0
    dist.histories[:] .= 0
    dist.sources[:] .= 0
    dist.predicates[:] .= 0
    dist.N = 0
    dist
end

function observe!(dist::TransferEntropy, source::AbstractArray{Int,3}, target::AbstractArray{Int,3})
    if size(source, 3) != size(target, 3)
        throw(ArgumentError("time series should have the same number of replicates"))
    end

    @views for i in 1:size(source, 3)
        observe!(dist, source[:,:,i], target[:,:,i])
    end

    dist
end

function observe!(dist::TransferEntropy, source::AbstractArray{Int,2}, target::AbstractArray{Int,2})
    if size(source, 2) != size(target, 2)
        throw(ArgumentError("time series should have the same number of timesteps"))
    elseif length(target) <= dist.k
        throw(ArgumentError("target series is too short given k=$(dist.k)"))
    elseif any(b -> b < 1, source) || any(b -> b < 1, target)
        throw(ArgumentError("observations must be positive, nonzero"))
    end

    N = size(target, 2) - 1
    dist.N += N - dist.k + 1
    history = 0
    @views for t in 1:dist.k
        history = dist.Bt*history + index(target[:,t], dist.bt) - 1;
    end
    @views for t in dist.k:N
        x, y = index(source[:,t], dist.bs), index(target[:,t+1], dist.bt)
        future = y - 1
        src = dist.Bs*history + x - 1
        predicate = dist.Bt*history + future
        state = dist.Bs*predicate + x - 1

        dist.states[state + 1] += 1
        dist.histories[history + 1] += 1
        dist.sources[src + 1] += 1
        dist.predicates[predicate + 1] += 1

        history = predicate - dist.q*(index(target[:,t-dist.k+1], dist.bt) - 1)
    end
    dist
end

function observe!(dist::TransferEntropy, source::AbstractArray{Int,1}, target::AbstractArray{Int,1})
    if length(source) != length(target)
        throw(ArgumentError("time series should have the same number of timesteps"))
    elseif length(target) <= dist.k
        throw(ArgumentError("target series is too short given k=$(dist.k)"))
    elseif any(b -> b < 1, source) || any(b -> b < 1, target)
        throw(ArgumentError("observations must be positive, nonzero"))
    end

    N = length(target) - 1
    dist.N += N - dist.k + 1
    history = 0
    @views for t in 1:dist.k
        history = dist.Bt*history + target[t] - 1;
    end
    @views for t in dist.k:N
        future = target[t + 1] - 1
        src = dist.Bs*history + source[t] - 1
        predicate = dist.Bt*history + future
        state = dist.Bs*predicate + source[t] - 1

        dist.states[state + 1] += 1
        dist.histories[history + 1] += 1
        dist.sources[src + 1] += 1
        dist.predicates[predicate + 1] += 1

        history = predicate - dist.q*(target[t - dist.k + 1] - 1)
    end
    dist
end

function estimate(dist::TransferEntropy)
    entropy(dist.sources, dist.N) +
    entropy(dist.predicates, dist.N) -
    entropy(dist.states, dist.N) -
    entropy(dist.histories, dist.N)
end

function transferentropy!(dist::TransferEntropy, source::AbstractArray{Int},
                          target::AbstractArray{Int})
    estimate(observe!(dist, source, target))
end

function transferentropy(source::AbstractArray{Int}, target::AbstractArray{Int}; kwargs...)
    estimate(TransferEntropy(source, target; kwargs...))
end

function transferentropy(::Type{Kraskov1}, xs::AbstractMatrix{Float64}, ys::AbstractMatrix{Float64};
                         k::Int=1, τ::Int=1, delay::Int=1, nn::Int=1, metric::Metric=Chebyshev())
    hs = history(ys, k, τ, delay)

    start = size(ys, 2) - size(hs, 2) + 1
    fs = @view ys[:, start:end]
    ss = @view xs[:, start-delay:end-delay]

    mutualinfo(Kraskov1, fs, ss, hs; nn=nn, metric=metric)
end

function transferentropy(::Type{Kraskov1}, xs::AbstractMatrix{Float64}, ys::AbstractMatrix{Float64},
                         cond::AbstractMatrix{Float64}, conds::AbstractMatrix{Float64}...;
                         k::Int=1, τ::Int=1, delay::Int=1, nn::Int=1, metric::Metric=Chebyshev())
    hs = history(ys, k, τ, delay)

    start = size(ys, 2) - size(hs, 2) + 1
    fs = @view ys[:, start:end]
    ss = @view xs[:, start-delay:end-delay]
    condview = @view cond[:, start-delay:end-delay]
    condviews = [@view c[:, start-delay:end-delay] for c in conds]

    mutualinfo(Kraskov1, fs, ss, hs, condview, condviews...; nn=nn, metric=metric)
end

function transferentropy(::Type{Kraskov}, xs::AbstractMatrix{Float64}, ys::AbstractMatrix{Float64},
                         cond::AbstractMatrix{Float64}...; kwargs...)
    transferentropy(Kraskov1, xs, ys, cond...; kwargs...)
end

function transferentropy(xs::AbstractMatrix{Float64}, ys::AbstractMatrix{Float64},
                         cond::AbstractMatrix{Float64}...; kwargs...)
    transferentropy(Kraskov1, xs, ys, cond...; kwargs...)
end

function transferentropy(xs::AbstractVector{Float64}, ys::AbstractVector{Float64},
                         cond::AbstractVector{Float64}...; kwargs...)
    conds = map(c -> reshape(c, 1, length(c)), cond)
    transferentropy(reshape(xs, 1, length(xs)), reshape(ys, 1, length(ys)), conds...; kwargs...)
end
