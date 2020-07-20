mutable struct TransferEntropy <: InfoDist
    k::Int
    states::Vector{Int}
    histories::Vector{Int}
    sources::Vector{Int}
    predicates::Vector{Int}
    bs::Int
    bt::Int
    q::Int
    N::Int

    function TransferEntropy(bs::Int, bt::Int, k::Int)
        if bs < 2 || bt < 2
            throw(ArgumentError("the support of each random variable must be at least 2"))
        end
        if k < 1
            throw(ArgumentError("history length must be at least 1"))
        end
        q = bt^k
        states = zeros(Int, bs*bt*q)
        histories = zeros(Int, q)
        sources = zeros(Int, bs*q)
        predicates = zeros(Int, bt*q)
        new(k, states, histories, sources, predicates, bs, bt, q, 0)
    end
end

function TransferEntropy(source::AbstractVector{Int}, target::AbstractVector{Int}, k::Int)
    if isempty(source) || isempty(target)
        throw(ArgumentError("arguments must not be empty"))
    end
    smin, smax = extrema(source)
    tmin, tmax = extrema(target)
    if smin < 1 || tmin < 1
        throw(ArgumentError("observations must be positive, nonzero"))
    end
    bs, bt = max(2, smax), max(2, tmax)
    observe!(TransferEntropy(bs, bt, k), source, target)
end

@inline function clear!(dist::TransferEntropy)
    dist.states[:] .= 0
    dist.histories[:] .= 0
    dist.sources[:] .= 0
    dist.predicates[:] .= 0
    dist.N = 0
    dist
end

function observe!(dist::TransferEntropy, source::AbstractVector{Int}, target::AbstractVector{Int})
    if length(source) != length(target)
        throw(ArgumentError("arguments must have the same length"))
    elseif length(target) <= dist.k
        throw(ArgumentError("target series is too short given k=$(dist.k)"))
    end
    rng = dist.k:(length(target)-1)
    dist.N += length(rng)
    history = 0
    for i in 1:dist.k
        history = dist.bt*history + target[i] - 1;
    end
    for i in rng
        future = target[i + 1] - 1
        src = dist.bs*history + source[i] - 1
        predicate = dist.bt*history + future
        state = dist.bs*predicate + source[i] - 1

        dist.states[state + 1] += 1
        dist.histories[history + 1] += 1
        dist.sources[src + 1] += 1
        dist.predicates[predicate + 1] += 1

        history = predicate - dist.q*(target[i - dist.k + 1] - 1)
    end
    dist
end

function estimate(dist::TransferEntropy)
    entropy(dist.sources, dist.N) +
    entropy(dist.predicates, dist.N) -
    entropy(dist.states, dist.N) -
    entropy(dist.histories, dist.N)
end

function transferentropy!(dist::TransferEntropy, source::AbstractVector{Int},
                          target::AbstractVector{Int})
    estimate(observe!(dist, source, target))
end

function transferentropy(source::AbstractVector{Int}, target::AbstractVector{Int}, k::Int)
    estimate(TransferEntropy(source, target, k))
end

function transferentropy(::Type{Kraskov1}, xs::AbstractMatrix{Float64}, ys::AbstractMatrix{Float64}, k::Int;
                         τ::Int=1, delay::Int=1, nn::Int=1, metric::Metric=Chebyshev())
    hs = history(ys, k, τ, delay)

    start = size(ys, 2) - size(hs, 2) + 1
    fs = @view ys[:, start:end]
    ss = @view xs[:, start-delay:end-delay]

    data = [fs; ss; hs]
    predicates = [fs; hs]
    sources = [ss; hs]

    joint = BallTree(data, metric)
    ms = BallTree(sources, metric)
    mp = BallTree(predicates, metric)
    mh = BallTree(hs, metric)

    N = size(data, 2)

    te = zero(Float64)
    δs = prevfloat.(last.(last(knn(joint, data, nn + 1, true))))
    @inbounds for i in 1:N
        ns = length(inrange(ms, sources[:, i], δs[i]))
        np = length(inrange(mp, predicates[:, i], δs[i]))
        nh = length(inrange(mh, hs[:, i], δs[i]))
        te += digamma(nh) - digamma(ns) - digamma(np)
    end
    digamma(nn) + (te/N)
end

function transferentropy(::Type{Kraskov}, xs::AbstractMatrix{Float64}, ys::AbstractMatrix{Float64}, k::Int; kwargs...)
    transferentropy(Kraskov1, xs, ys, k; kwargs...)
end

function transferentropy(xs::AbstractMatrix{Float64}, ys::AbstractMatrix{Float64}, k::Int; kwargs...)
    transferentropy(Kraskov1, xs, ys, k; kwargs...)
end

function transferentropy(xs::AbstractVector{Float64}, ys::AbstractVector{Float64}, k::Int; kwargs...)
    transferentropy(reshape(xs, 1, length(xs)), reshape(ys, 1, length(ys)), k; kwargs...)
end
