# This will replace instrument.jl, sounds, notes, tones
"""
        An Instrument takes a 
        - frequency (Hz)
        - duration (sec)
        - loudness (relative to 1)
        and produces a Sound

        `play(i(440, 1, 1))`
        An Instrument applied to a vector of frequencies plays a chord.
        `i([100, 125, 150])
        To play the frequences as a melody, broadcast over the vector and use `melody` to play them in sequnce:
        `melody(i.([100, 125, 150]))`
        
"""
abstract type AbstractInstrument end

"""
        A Synthesizer consists of 2 functors returning functions
        - osc: takes a frequency
        - end: takes duration (in sec) and amplitude

        A synthesizers is an Amstract Instrument and thus callable taking
        - frequency (Hz)
        - duration (sec)
        - loudness (relative to 1)
        as input and returning a Sound
example:

```
sin1(t) = sin(t*2pi)

function harm1(f)
    return t -> sin1(t*f)
end

function tri1(t)
    t <= 0 && return 0
    t >= 1 && return 0
    t <= .5 && return 2t
    return 2-2t
end

function tri(d, l=1)
    t -> l*tri1(t/d)
end

     
i1 = Synthesizer(harm1, tri)

using Plots
plot(
        plot(harm1(10), -1, 3, label="osc"),
        plot(tri(2,1), -1, 3, label = "env"),
        plot(i1(10, 2, 1).fun, -1, 3, label = "sound"),
        layout = (3,1), 
)
play_wav(i1(100,1,1))
```        

An synthesizer can play chords by applying it to a vector of frequencies.

Example:
```
plot(i1([5,10],4).fun)
```

"""
struct Synthesizer <: AbstractInstrument
    oscillator::Function
    envelope::Function
end

"""
        synthesizer(osc, env; osc_kw, env_kw)
        produces a Synthesizer from and oscillator and an envelope.
        
        The oscilator is a 1-periodic function and can take kw arguments from osc_kw
        The envelope is a function of (t, d) that is 0 outside [0; d], has a maximum of about 1 and can take kw_arguments from env_kw

Excample
``` julia

harm(t; phi=0) = sin(t*2pi + phi)

function tri(t, d=1; t1=.5)         
    t = t/d
    t <= 0 && return 0
    t >= 1 && return 0
    t <= t1 && return t/t1
    return (1/(1-t1)-t/(1-t1))
end

i2 = synthesizer(harm, tri; osc_kw=(;phi=0), env_kw = (;t1=.5))
i3 = synthesizer(harm, tri)
   
```        

"""
function synthesizer(osc, env; osc_kw=(;), env_kw=(;))
    o1 = f -> (t -> osc(t*f;osc_kw...))
    e1 = (d,l) -> (t -> l*env(t,d; env_kw...))
    Synthesizer(o1, e1)
end

"""
        A Sound is a function that plays between t_start and t_end (in seconds)

        A Sound can be sampled and played.
        A vecor of Sounds are played as a chord.
        A vector of Sounds can be sequenced to a melody to be played on after an other.
        `play(melody([s1, s2, s3]))`
        `play([s1, s2, s3])`
                
"""
struct Sound{T}
    fun::Function
    t_start::T #sec
    t_end::T #sec
end

(i::Synthesizer)(f::T, d=1, l=1) where {T <: Number} = Sound(t -> i.oscillator(f)(t)*i.envelope(d,l)(t),  0, d)

## Chords
import Base.+

(+)(f1::Function, f2::Function) = x -> f1(x) + f2(x)

"""
        Sounds can be added.
        The sound functions are added as functions and is plays from minimum of start times to maximum of end times.
"""
(+)(s1::Sound, s2::Sound) = Sound(x -> s1.fun(x) + s2.fun(x), min(s1.t_start, s2.t_start), max(s1.t_end, s2.t_end))

# Playing a chord is summing the sounds
function (i::S where {S <: AbstractInstrument})(f::Vector{T}, d=1, l=1) where {T}
    sum(i.(f, d, l))
end

function dilate(f::Function, d)
    return t -> f(t-d)
end
dilate(s::Sound, d) = Sound(dilate(s.fun, d), s.t_start + d, s.t_end + d)

"""
    melody(s::Vector{Sound{T}}) where T
    turns a vector of sounds into a melody (a single Sound) by playing the sounds in succession

Example:
```
plot(melody(i1.([5,10])).fun)
```
"""
function melody(s::Vector{Sound{T}}) where T
    dilated = Sound{T}[]
    push!(dilated, s[1])
    for i in eachindex(s)
        i == 1 && continue
        push!(dilated, dilate(s[i], dilated[i-1].t_end))
    end
    @show dilated
    sum(dilated)
end


function sample(s::Sound; samplerate = 44100)
    seconds = (s.t_end - s.t_start) * 1.0f0
    x = 0:1/samplerate:prevfloat(seconds)
    y = s.fun.(x)
    y
end


# TODO: the Instrument should tell the Sound how much release to add
function play_wav(s::Sound; samplerate = 44100, file = tempname(), play = true, release = 1)
    seconds = (s.t_end - s.t_start + release) * 1.0f0
    x = 0:1/samplerate:prevfloat(seconds)
    y = s.fun.(x)
    y = y ./ maximum(y) # rescale y
    WAV.wavwrite(y, file, Fs = samplerate)
    play && WAV.wavplay(file)
    file
end

# ADSR envelope
"""
        adsr(t, d; A=0.1, D=0.1, S=0.9, R=0.1)
        t: time variable
        d: duration. Time when Release sets in
        A: attac. Time to reach 1 (in sec)
        D: decay. Time to reach S
        S: sustain. Fraction of loudness sustained
        R: Release. Time to dreach 0 after note end

If d < A+D, we rescale A and D by d/(A+D).

Example

```
harm(t; phi=0) = sin(t*2pi + phi)
i4 = synthesizer(harm, adsr)

```
"""
function adsr(t, d; A=0.1, D=0.1, S=0.9, R=0.1)
    if A+D > d
        A = A*d/(A+D)
        D = D*d/(A+D)
        @show A, D, d
    end
    D2 = A + D
    t <= 0     && return zero(A)
    t >= d + R && return zero(A)
    t <= A     && return t/A 
    t <= D2    && return (1-S)*(A/(A-D2)-t/(A-D2)) + S
    t >=d      && return S*((d+R)/R-t/R)
    return S
end
