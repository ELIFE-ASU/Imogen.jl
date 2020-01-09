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

