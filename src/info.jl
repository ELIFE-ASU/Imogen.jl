abstract type EmpericalDist end

"""
    observe!(d, args...)
"""
observe!(::EmpericalDist, args...)

"""
    estimate(d)
"""
estimate(::EmpericalDist)
