mutable struct SIDist <: InfoDist
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

function observe!(dist::SIDist, x1::AbstractVector{Int}, x2::AbstractVector{Int})
    dist.N += length(x1)
    for i in eachindex(x1)
        dist.joint[x1[i], x2[i]] += 1
        dist.m1[x1[i]] += 1
        dist.m2[x2[i]] += 1
    end
    dist
end

function estimate(dist::SIDist)
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
    estimate(observe!(dist, stimulus, boxed))
end

function specificinfo(stimulus::AbstractVector{Int}, responses::AbstractVector{Int})
    dist = SIDist(maximum(stimulus), maximum(responses))
    estimate(observe!(dist, stimulus, responses))
end

function specificinfo(stimulus::AbstractVector{Int}, responses::AbstractMatrix{Int},
                      subset::AbstractVector{Int})
    specificinfo(stimulus, @view responses[subset, :])
end
