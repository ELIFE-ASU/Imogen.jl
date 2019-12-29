function subsets(n::Int)
    if n < 1
        throw(DomainError(n, "must be greater than or equal to 1"))
    end
    m = 1 << n
    ss = Vector{Vector{Int}}(undef, m - 1)
    for i in 2:m
        s = Int[]
        for j in 1:n
            if (i - 1) & (1 << (j-1)) != 0
                push!(s, j)
            end
        end
        ss[i-1] = s
    end
    ss
end

function box(series::AbstractMatrix{Int})
    b = max(2, maximum(series))
    boxed = zeros(Int, size(series, 2))
    for j in 1:size(series, 2)
        for i in 1:size(series, 1)
            boxed[j] = b*boxed[j] + series[i, j] - 1
        end
        boxed[j] += 1
    end
    boxed
end

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
