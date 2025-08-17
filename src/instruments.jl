# An instrument takes Tone and a tempo, and returns a Sound
# First example is the sound_func from before.
# we can write functors to create them
struct Instrument
    synth::Function ## (t::Tone ; bpm = 60, t_start = 0)::Sound
end

using Roots
using ForwardDiff
using StatsBase

function step_up(t, t_0)
    t >= t_0 ? 1. : 0.
end

function step_down(t, t_0)
    t >= t_0 ? 0. : 1.
end


function find_end(f, t_2)
    zeros = find_zeros(f, (t_2, t_2+0.1))
    grads = ForwardDiff.derivative.(f, zeros)
    first(zeros[ grads .>=0 ])
end


function _sine(t::Tone, bpm = 60, t_start = 0)
    oscillator = (x -> sin(2pi * x)) # 1-peroidinc function
    freq = t.frequency
    loud = t.note.loudness
    l = length(freq)
    seconds = t.note.duration * 60/bpm
    @assert length(loud) == l
    f1(t) = sum([loud[n] * oscillator(freq[n]*(t - t_start)) for n=1:l])
    t_end = find_end(f1, t_start + seconds)
    func(t) = f1(t) * step_up(t, t_start) * step_down(t, t_end)
    Sound(func, [t], t_start, t_end)
end


sine = Instrument(_sine)


function ramp_up(t, t0 = 0., t1 = 1.)
    t <= t0 && return(0.)
    t >= t1 && return(1.)
    return((t-t0) / (t1-t0))
end
function ramp_down(t, t0 = 0., t1 = 1.)
    t <= t0 && return(1.)
    t >= t1 && return(0.)
    return(1 - ((t-t0) / (t1-t0)))
end

function _sine_ar(t::Tone, bpm = 60, t_start = 0; attack = 0.005, release = 0.005)
    ## sine function with 100ms attach and 100ms release
    oscillator = (x -> sin(2pi * x)) # 1-peroidinc function
    freq = t.frequency
    loud = t.note.loudness
    l = length(freq)
    seconds = t.note.duration * 60/bpm
    @assert length(loud) == l
    f1(t) = sum([loud[n] * oscillator(freq[n]*(t - t_start)) for n=1:l])
    t_end = t_start + seconds + release
    func(t) = f1(t) * ramp_up(t, t_start, t_start+attack) * ramp_down(t,  t_start + seconds, t_end)
    Sound(func, [t], t_start, t_end)
end

sine_ar = Instrument(_sine_ar)

