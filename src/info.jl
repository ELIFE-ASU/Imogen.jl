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

mutable struct SIDist
    joint::Matrix{Int}
    m1::Vector{Int}
    m2::Vector{Int}
    b1::Int
    b2::Int
    N::Int
    function SIDist(b1::Int, b2::Int)
        new(zeros(Int, b1, b2), zeros(Int, b1), zeros(Int, b2), b1, b2, 0)
    end
end

function accumulate!(dist::SIDist, x1::AbstractVector{Int}, x2::AbstractVector{Int})
    dist.N += length(x1)
    for i in eachindex(x1)
        dist.joint[x1[i], x2[i]] += 1
        dist.m1[x1[i]] += 1
        dist.m2[x2[i]] += 1
    end
    dist
end

function entropy(dist::SIDist)
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

function specificinfo(stimulus::AbstractVector{Int}, responses::AbstractMatrix{Int})
    boxed = box(responses)
    dist = SIDist(maximum(stimulus), maximum(boxed))
    entropy(accumulate!(dist, stimulus, boxed))
end

function specificinfo(stimulus::AbstractVector{Int}, responses::AbstractVector{Int})
    dist = SIDist(maximum(stimulus), maximum(responses))
    entropy(accumulate!(dist, stimulus, responses))
end

function specificinfo(stimulus::AbstractVector{Int}, responses::AbstractMatrix{Int},
                      subset::AbstractVector{Int})
    specificinfo(stimulus, @view responses[subset, :])
end
