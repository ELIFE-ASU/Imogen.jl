mutable struct TEDist <: EmpericalDist
    k::Int
    states::Vector{Int}
    histories::Vector{Int}
    sources::Vector{Int}
    predicates::Vector{Int}
    N::Int

    function TEDist(k::Int)
        q = 2^k
        states = zeros(Int, 4q)
        histories = zeros(Int, q)
        sources = zeros(Int, 2q)
        predicates = zeros(Int, 2q)
        new(k, states, histories, sources, predicates, 0)
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

function observe!(dist::TEDist, xs::AbstractVector{Int}, ys::AbstractVector{Int})
    rng = dist.k:(length(ys)-1)
    dist.N = length(rng)
    history, q = 0, 1
    @inbounds for i in 1:dist.k
        q *= 2
        history = 2history + ys[i] - 1;
    end
    @inbounds for i in rng
        src = xs[i] - 1
        future = ys[i + 1] - 1
        source = 2history + src
        predicate = 2history + future
        state = 2predicate + src

        dist.states[state + 1] += 1
        dist.histories[history + 1] += 1
        dist.sources[source + 1] += 1
        dist.predicates[predicate + 1] += 1

        history = predicate - q*(ys[i - dist.k + 1] - 1)
    end
    dist
end

function estimate(dist::TEDist)
    entropy(dist.sources, dist.N) +
    entropy(dist.predicates, dist.N) -
    entropy(dist.states, dist.N) -
    entropy(dist.histories, dist.N)
end

function transferentropy!(dist::TEDist, xs::AbstractVector{Int}, ys::AbstractVector{Int})
    estimate(observe!(dist, xs, ys))
end

function transferentropy(xs::AbstractVector{Int}, ys::AbstractVector{Int}, k::Int)
    transferentropy!(TEDist(k), xs, ys)
end
