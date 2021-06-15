using Base.Meta
using Distributions: Chisq, cdf

abstract type Significance end

struct EmpiricalSig{T<:Real} <: Significance
    gt::T
    count::Int
    values::Vector{T}
    p::Float64
    se::Float64

    function EmpiricalSig(gt::T, values::AbstractArray{T,1}) where {T<:Real}
        N = length(values)
        p = count(gt .≤ values) / N
        se = sqrt((p * (1-p))/N)
        new{T}(gt, N, values, p, se)
    end
end

function sig(::Type{EmpiricalSig}, func::Function, args::AbstractArray{<:Number,3}...;
             nperm=1000, parg=1, rng=Random.defautl_rng(), kwargs...)

    gt = func(args...; kwargs...)
    values = zeros(typeof(gt), nperm + 1)
    values[1] = gt
    head, arg, tail = args[1:parg-1], args[parg], args[parg+1:end]
    @views for i in 1:nperm
        perm = randperm(rng, size(arg, 2))
        values[i+1] = func(head..., arg[:,perm,:], tail...; kwargs...)
    end
    EmpiricalSig(gt, values)
end

function sig(::Type{EmpiricalSig}, func::Function, args::AbstractArray{<:Number,2}...;
             nperm=1000, parg=1, rng=Random.default_rng(), kwargs...)

    gt = func(args...; kwargs...)
    values = zeros(typeof(gt), nperm + 1)
    values[1] = gt
    head, arg, tail = args[1:parg-1], args[parg], args[parg+1:end]
    @views for i in 1:nperm
        perm = randperm(rng, size(arg, 2))
        values[i + 1] = func(head..., arg[:,perm], tail...; kwargs...)
    end
    EmpiricalSig(gt, values)
end

function sig(::Type{EmpiricalSig}, func::Function, args::AbstractArray{<:Number,1}...;
             nperm=1000, parg=1, rng=Random.default_rng(), kwargs...)

    gt = func(args...; kwargs...)
    values = zeros(typeof(gt), nperm + 1)
    values[1] = gt
    head, arg, tail = args[1:parg-1], args[parg], args[parg+1:end]
    @views for i in 1:nperm
        perm = randperm(rng, length(arg))
        values[i + 1] = func(head..., arg[perm], tail...; kwargs...)
    end
    EmpiricalSig(gt, values)
end

struct AnalyticSig{T<:Real} <: Significance
    gt::T
    N::Int
    dof::Float64
    dist::Chisq
    p::Float64
    function AnalyticSig(gt::T, N::Int, dof::Integer) where {T<:Real}
        dist = Chisq(dof)
        p = 1 - cdf(dist, 2 * N * gt)
        new{T}(gt, N, dof, dist, p)
    end
end

function sig(::Type{AnalyticSig}, func::Function, args::AbstractArray{<:Integer,3}...;
             nperm=1000, parg=1, rng=Random.default_rng(), kwargs...)
    gt = func(args...; kwargs...)
    dof = prod(map(a -> prod(maximum(a; dims=(2,3))) - 1, args))
    AnalyticSig(gt, size(args[1], 2), dof);
end

function sig(::Type{AnalyticSig}, func::Function, args::AbstractArray{<:Integer,2}...;
             nperm=1000, parg=1, rng=Random.default_rng(), kwargs...)
    gt = func(args...; kwargs...)
    dof = prod(map(a -> prod(maximum(a; dims=2)) - 1, args))
    AnalyticSig(gt, size(args[1], 2), dof);
end

function sig(::Type{AnalyticSig}, func::Function, args::AbstractArray{<:Integer,1}...;
             nperm=1000, parg=1, rng=Random.default_rng(), kwargs...)
    gt = func(args...; kwargs...)
    dof = prod(map(a -> prod(maximum(a)) - 1, args))
    AnalyticSig(gt, length(args[1]), dof);
end

macro sig(method, func, args...)
    if !isexpr(func, :call)
        error("first expression must be a function call")
    end

    kwargs = Dict{Any,Any}(:nperm => 1000, :parg => 1, :rng => :(Random.default_rng()))
    foreach(args) do arg
        if isexpr(arg, :(=))
            kwargs[arg.args[1]] = arg.args[2]
        else
            error("each argument after the first must be a keyword argument")
        end
    end

    kw = if length(func.args) ≥ 2 && isexpr(func.args[2], :parameters)
        append!(func.args[2].args, [Expr(:kw, arg[1], arg[2]) for arg in kwargs])
        func.args[2]
    else
        Expr(:parameters, [Expr(:kw, arg[1], arg[2]) for arg in kwargs]...)
    end

    if length(func.args) == 1
        func.args = [:sig, kw, method, func.args[1]]
    elseif length(func.args) == 2 && isexpr(func.args[2], :parameters)
        func.args = [:sig, kw, method, func.args[1]]
    elseif isexpr(func.args[2], :parameters)
        func.args = [:sig, kw, method, func.args[1], func.args[3:end]...]
    else
        func.args = [:sig, kw, method, func.args...]
    end

    esc(func)
end
