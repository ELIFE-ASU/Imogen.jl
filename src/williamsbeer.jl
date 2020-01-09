mutable struct WilliamsBeer
    Iₘᵢₙ::Float64
    Π::Float64
end
Base.zero(::Type{WilliamsBeer}) = WilliamsBeer(0.0, 0.0)

function Base.isequal(p::WilliamsBeer, q::WilliamsBeer)
    isequal(p.Iₘᵢₙ, q.Iₘᵢₙ) && isequal(p.Π, q.Π)
end

Base.:(==)(p::WilliamsBeer, q::WilliamsBeer) = p.Iₘᵢₙ == q.Iₘᵢₙ && p.Π == q.Π

Base.:≈(p::WilliamsBeer, q::WilliamsBeer) = p.Iₘᵢₙ ≈ q.Iₘᵢₙ && p.Π ≈ q.Π

Base.iszero(p::WilliamsBeer) = p.Π == zero(p.Π)

Base.show(io::IO, ::MIME"text/dot", p::WilliamsBeer) = print(io, "Iₘᵢₙ = ", p.Iₘᵢₙ, ", Π = ", p.Π)

mutable struct Dist
    data::Vector{Int}
    b::Int
    N::Int
    Dist(b) = new(zeros(Int, b), b, 0)
end

function accumulate!(dist::Dist, xs::AbstractVector{Int})
    dist.N += length(xs)
    for i in eachindex(xs)
        dist.data[xs[i]] += 1
    end
    dist
end

Base.length(dist) = dist.b

Base.getindex(dist, idx...) = getindex(dist.data, idx...)

function pid!(h::Hasse{<:AbstractVertex{WilliamsBeer}},
             stimulus::AbstractVector{Int},
             responses::AbstractMatrix{Int};
             zero=true)
    if zero
        zero!(h)
    end

    bs = maximum(stimulus)

    L = size(responses, 1)
    ss = subsets(L)
    si = Vector{Vector{Float64}}(undef, length(ss))
    for i in eachindex(ss)
        si[i] = specificinfo(stimulus, responses, ss[i])
    end

    sdist = accumulate!(Dist(maximum(stimulus)), stimulus)

    for i in eachindex(h)
        α = h[i]
        for s in 1:bs
            x = si[α[1]][s]
            for k in 2:length(α)
                x = min(x, si[α[k]][s])
            end
            payload(α).Iₘᵢₙ += sdist[s] * x;
        end
        payload(α).Iₘᵢₙ /= sdist.N;
    end

    for i in eachindex(h)
        α = h[i]
        for s in 1:bs
            u = -Inf
            for β in below(α)
                x = si[β[1]][s]
                for k in 2:length(β)
                    x = min(x, si[β[k]][s])
                end
                u = max(u, x)
            end
            if isinf(u)
                u = 0.0
            end
            payload(α).Π += sdist[s] * u
        end
        payload(α).Π = payload(α).Iₘᵢₙ - payload(α).Π / sdist.N
    end

    h
end

function pid(::Type{WilliamsBeer}, stimulus::AbstractVector{Int}, responses::AbstractMatrix{Int})
    pid!(Hasse(WilliamsBeer, size(responses,1)), stimulus, responses; zero=false)
end

function pid(::Type{WilliamsBeer},
             stimulus::AbstractVector{Int},
             responses::AbstractMatrix{Int},
             names::AbstractVector)
    if length(names) != size(responses,1)
        throw(ArgumentError("number of names provided does not match the number of responses"))
    end

    pid!(Hasse(WilliamsBeer, names), stimulus, responses; zero=false)
end
