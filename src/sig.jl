using Random

mutable struct Sig{T <: Real}
    value::T
    p::T
    se::T
end

macro sig(func, args...)
    if !isexpr(func, :call)
        error("first expression must be a function call")
    end

    kwargs = Dict{Any,Any}(:nperm => 1000, :parg => 1, :rng => Random.GLOBAL_RNG)
    foreach(args) do arg
        if isexpr(arg, :(=))
            kwargs[arg.args[1]] = arg.args[2]
        else
            error("each argument after the first must be a keyword argument")
        end
    end

    quote
        local nperm = $(esc(kwargs[:nperm]))
        local parg = $(esc(kwargs[:parg]))
        local rng = $(esc(kwargs[:rng]))
        local func = $(esc(func.args[1]))
        local args = [$(esc.(func.args[2:end])...)]

        local front, permarg, back = args[1:parg-1], args[parg], args[parg+1:end]
        local N = length(permarg)

        local count = 1
        local gt = func(front..., permarg, back...)
        @views for _ in 1:nperm
            count += (gt ≤ func(front..., permarg[randperm(rng, N)], back...))
        end
        local p = count / (nperm + 1)
        local se = sqrt((p * (1 - p)) / (nperm + 1))
        Sig(gt, p, se)
    end
end
