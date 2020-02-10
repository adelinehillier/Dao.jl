const second = 1
const minute = 60 * second
const hour = 60 * minute
const day = 24 * hour

"""
    prettytime(t)

Convert a floating point value `t` representing an amount of time in seconds to a more
human-friendly formatted string with three decimal places. Depending on the value of `t`
the string will be formatted to show `t` in nanoseconds (ns), microseconds (μs),
milliseconds (ms), seconds (s), minutes (min), hours (hr), or days (day).
"""
function prettytime(t)
    # Modified from: https://github.com/JuliaCI/BenchmarkTools.jl/blob/master/src/trials.jl
    iszero(t) && return "0.000 s"

    if t < 1e-6
        value, units = t * 1e9, "ns"
    elseif t < 1e-3
        value, units = t * 1e6, "μs"
    elseif t < 1 
        value, units = t * 1e3, "ms"
    elseif t < minute
        value, units = t, "s" 
    elseif t < hour
        value, units = t / minute, "min"
    elseif t < day 
        value, units = t / hour, "hr"
    else
        value, units = t / day, "day"
    end 

    return @sprintf("%.3f", value) * " " * units
end

function collect_samples(chain)
    parameter_samples = zeros(length(chain.links[1].param), length(chain))
    for (i, link) in enumerate(chain.links)
        @inbounds parameter_samples[:, i] .= link.param
    end
    return parameter_samples
end
