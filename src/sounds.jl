struct Sound
    func::Function
    tone::Vector{Tone}
    seconds::Float32
end

function step_up(t, t_0)
    t >= t_0 ? 1. : 0.
end

function step_down(t, t_0)
    t >= t_0 ? 0. : 1.
end

using Roots
using ForwardDiff

function find_end(f, t_2)
    zeros = find_zeros(f, (t_2, t_2+0.1))
    grads = ForwardDiff.derivative.(f, zeros)
    first(zeros[ grads .>=0 ])
end

using StatsBase

function sound_func(t::Tone, i::Instrument; bpm = 60, t_start = 0)
    freq = t.frequency
    loud = t.note.loudness
    l = length(freq)
    seconds = t.note.duration * 60/bpm
    @assert length(loud) == l
    f1(t) = mean([loud[n] * i.synth(freq[n]*(t - t_start)) for n=1:l])
    t_end = find_end(f1, t_start + seconds)
    func(t) = f1(t) * step_up(t, t_start) * step_down(t, t_end)
    (func, t_end)
end

function sound(t::Tone, i::Instrument; bpm = 60, t_start = 0)
    (f,t_end) = sound_func(t,i;bpm, t_start)
    Sound(t, [t], t_end)
end

function sound(m::Melody, i::Instrument; bpm=60, tuning=tet12)
    funcs = Function[]
    tones = Tone[]
    local t_end
    t_start = 0.
        for note in m.notes
            t = tone(note; tuning)
            (f, t_end) = sound_func(t, i; bpm, t_start)
            push!(funcs, f)
            t_start = t_start + note.duration*60/bpm
        end
    f(t) = sum([f(t) for f in funcs])
    Sound(f, tones, t_end)
end

function sample(s::Sound; samplerate = 44100)
    x = 0:1/samplerate:prevfloat(s.duration)
    y = s.func.(x)
    y
end



function play_wav(s::Sound; samplerate = 44100, file = tempname(), play = true)
    x = 0:1/samplerate:prevfloat(s.seconds)
    y = s.func.(x)
    WAV.wavwrite(y, file, Fs = samplerate)
    play && WAV.wavplay(file)
    file
end

import Base.(+)
function +(a::A,b::B) where {A <: Function , B <: Function}
    x -> a(x) + b(x)
end
