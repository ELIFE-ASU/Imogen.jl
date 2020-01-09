function pid(::Type{T}, stimulus::AbstractVector{Int}, responses::AbstractMatrix{Int}) where T
    pid!(Hasse(T, size(responses,1)), stimulus, responses; zero=false)
end

function pid(::Type{T}, stimulus::AbstractVector{Int},
             responses::AbstractMatrix{Int},
             names::AbstractVector) where T
    if length(names) != size(responses,1)
        throw(ArgumentError("number of names provided does not match the number of responses"))
    end

    pid!(Hasse(T, names), stimulus, responses; zero=false)
end

function pid!(h::Hasse, df::DataFrame, stimulus, responses, args...; kwargs...)
    pid!(h, df[:, stimulus], transpose(Array(df[:, responses])), args...; kwargs...)
end

function pid(::Type{T}, df::DataFrame, stimulus, responses, args...; kwargs...) where T
    pid(T, df[:, stimulus], transpose(Array(df[:, responses])), responses, args...; kwargs...)
end
