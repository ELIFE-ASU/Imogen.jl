abstract type InfoDist end

"""
    observe!(d, args...)
"""
observe!(::InfoDist, args...)

"""
    clear!(d)
"""
clear!(::InfoDist)

"""
    estimate(d)
"""
estimate(::InfoDist)
