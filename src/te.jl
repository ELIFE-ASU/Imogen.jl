mutable struct TEDist <: InfoDist
    k::Int
    states::Vector{Int}
    histories::Vector{Int}
    sources::Vector{Int}
    predicates::Vector{Int}
    bs::Int
    bt::Int
    q::Int
    N::Int

    function TEDist(bs::Int, bt::Int, k::Int)
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

@inline function clear!(dist::TEDist)
    dist.states[:] .= 0
    dist.histories[:] .= 0
    dist.sources[:] .= 0
    dist.predicates[:] .= 0
    dist.N = 0
    dist
end

function observe!(dist::TEDist, source::AbstractVector{Int}, target::AbstractVector{Int})
    rng = dist.k:(length(target)-1)
    dist.N = length(rng)
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

function estimate(dist::TEDist)
    entropy(dist.sources, dist.N) +
    entropy(dist.predicates, dist.N) -
    entropy(dist.states, dist.N) -
    entropy(dist.histories, dist.N)
end

function transferentropy!(dist::TEDist, source::AbstractVector{Int}, target::AbstractVector{Int})
    estimate(observe!(dist, source, target))
end

function transferentropy(source::AbstractVector{Int}, target::AbstractVector{Int}, k::Int)
    smin, smax = extrema(source)
    tmin, tmax = extrema(target)
    if smin < 1 || tmin < 1
        throw(ArgumentError("observations must be positive, nonzero"))
    end
    bs, bt = max(2, smax), max(2, tmax)
    transferentropy!(TEDist(bs, bt, k), source, target)
end
