"""
        Instrument(synth, envelope)
        synth is a 1-periodic tone-generating function
        It must satisfy f(0)==0, f'(0) >=0
        envelope is a functon with signature
        e(f::Function, t_start, t_stop)
        taking a synth function and start and stop time (in seconds)
        It retuns a new tone-generating function, f, and a new t_end (t_end >= t_stop)
        where f is zero outside t_start, t_end
        The envelope can also take keyword parameters (like bpm)
"""
struct Instrument{S <: Function, T <: Function}
    synth::S ## 1-periodic
    envelope::T
end

## sine(frequency; phase = 0, amplitude = 1) = Instrument(x -> amplitude * sin(2pi * frequency + phase))

function adaptive_step(f, t_start, t_stop)
    ## find t_end
    zeros = find_zeros(f, (t_stop, t_stop+0.1))
    grads = ForwardDiff.derivative.(f, zeros)
    t_end = first(zeros[ grads .>=0 ])
    func(t) = f(t) * step_up(t, t_start) * step_down(t, t_end)
    (func, t_end)
end

sin_one(t) = sin(2pi * t)

sine1 = Instrument(x -> sin(2pi * x), x -> 1)
sine = Instrument(sin_one, adaptive_step)

function step_up(t, t_0)
    t >= t_0 ? 1. : 0.
end

function step_down(t, t_0)
    t >= t_0 ? 0. : 1.
end


