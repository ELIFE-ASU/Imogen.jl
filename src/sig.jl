using Random

mutable struct Sig{T <: Real}
    value::T
    p::T
    se::T
end

function sig(func::Function, args...; nperm=1000, parg=1, kwargs...)
    sig(Random.GLOBAL_RNG, func, args...; nperm=nperm, parg=parg, kwargs...)
end

function sig(rng::AbstractRNG, func::Function, args...; nperm=1000, parg=1, kwargs...)
    front, permarg, back = args[1:parg-1], args[parg], args[parg+1:end]
    N = length(permarg)
    count = 1
    gt = func(front..., permarg, back...)
    @views for _ in 1:nperm
        count += (gt ≤ func(front..., permarg[randperm(rng, N)], back...; kwargs...))
    end
    p = count / (nperm + 1)
    se = sqrt((p * (1 - p)) / (nperm + 1))
    Sig(gt, p, se)
end

macro sig(e::Expr)
    :(sig($(esc.(e.args)...)))
end

macro sig(nperm, e::Expr)
    :(sig($(esc.(e.args)...); nperm=$(esc(nperm))))
end
