abstract type InfoDist end

"""
    observe!(d, args...)
"""
observe!(::InfoDist, args...)

"""
    estimate(d)
"""
estimate(::InfoDist)
