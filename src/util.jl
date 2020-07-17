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
	smin, smax = extrema(series)
    b = max(2, smin - smax + 1)
    boxed = zeros(Int, size(series, 2))
    for j in 1:size(series, 2)
        for i in 1:size(series, 1)
            boxed[j] = b*boxed[j] + series[i, j] - smin
        end
        boxed[j] += 1
    end
    boxed
end

function histories(series::AbstractVector{Int}, k::Int; warn=true)
    if k < 1
        throw(ArgumentError("history length must be greater than 0"))
    end

    if warn
        smin, smax = extrema(series)
        b = max(2, smax - smin + 1)
        if b^k > length(series) - k + 1
            @warn "With only $(length(series)) observations, it is impossible to observe all $b^$k possible histories; consider reducing k or increasing the number of histories"
        end
    end

    hs = Array{Int}(undef, k, length(series) - k + 1)
    for i in 1:length(series) - k + 1
        hs[:,i] = series[i:i+k-1]
    end
    hs
end

function history(ys::AbstractMatrix{T}, k::Int, τ::Int=1, delay::Int=1) where T
	start = 1 + max((k-1)*τ+1, delay)
    N, M = size(ys)
    hs = Array{T}(undef, N*k, M - start + 1)
    for i in start:M
        for j in 1:k
            hs[N*(j-1) .+ (1:N), i - start + 1] = ys[:, i - (k-1)*τ - 1 + τ*(j-1)]
        end
    end
    hs
end

function recode!(dst::AbstractVector{Int}, src::AbstractVector{Int}=dst)
    map = Dict{Int,Int}()
    k = 0
    for (i, x) in enumerate(src)
        dst[i] = if !haskey(map, x)
            map[x] = (k += 1)
        else
            map[x]
        end
    end
    dst
end

recode(src::AbstractVector{Int}) = recode!(similar(src), src)

function encodehistories(series::AbstractVector{Int}, k::Int; warn=true, recode=false)
    if k < 1
        throw(ArgumentError("history length must be greater than 0"))
    end

    smin, smax = extrema(series)
    b = max(2, smax - smin + 1)
    if warn
        if b^k > length(series) - k + 1
            @warn "With only $(length(series)) observations, it is impossible to observe all $b^$k possible histories; consider reducing k or increasing the number of histories"
        end
    end

    hs = Array{Int}(undef, length(series) - k + 1)
    map = Dict{Int,Int}()
    u = 0
    for i in 1:length(series) - k + 1
        h = 0
        for j in 0:k-1
            h = b * h + series[i + j] - smin
        end

        if recode
            hs[i] = if !haskey(map, h)
                map[h] = (u += 1)
            else
                map[h]
            end
        else
            hs[i] = h + 1
        end
    end
    hs
end
