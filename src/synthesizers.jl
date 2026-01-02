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

harm_osc(t; phi=0) = sin(t*2pi + phi)

function tri_env(t, d=1; t1=.5)         
    t = t/d
    t <= 0 && return 0
    t >= 1 && return 0
    t <= t1 && return t/t1
    return (1/(1-t1)-t/(1-t1))
end

i2 = synthesizer(harm_osc, tri_env; osc_kw=(;phi=0), env_kw = (;t1=.5))
i3 = synthesizer(harm_osc, tri_env)
   
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

(i::Synthesizer)(f::T, d=1, l=1) where {T <: Number} = Sound(t -> i.oscillator(f)(t)*i.envelope(d,l)(t),  zero(d), d)

# Example synth: single harmonic, triangle envelope
"""
        Example socillator: single harmonic oscillator
        harm_osc(t; phi=0) = sin(t*2pi + phi)

Example
```
i2 = synthesizer(harm_osc, tri_env; osc_kw=(;phi=0), env_kw = (;t1=.5))
```        
"""
harm_osc(t; phi=0) = sin(t*2pi + phi)
function tri_env(t, d=1; t1=.5)         
    t = t/d
    t <= 0 && return 0
    t >= 1 && return 0
    t <= t1 && return t/t1
    return (1/(1-t1)-t/(1-t1))
end


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


function sample(s::Sound; samplerate = 44100, release = 1)
    seconds = (s.t_end - s.t_start + release) * 1.0f0
    x = 0:1/samplerate:prevfloat(seconds)
    y = s.fun.(x)
    y
end


# TODO: the Instrument should tell the Sound how much release to add
function play_wav(s::Sound; samplerate = 44100, file = tempname(), play = true, release = 1)
    # seconds = (s.t_end - s.t_start + release) * 1.0f0
    # x = 0:1/samplerate:prevfloat(seconds)
    # y = s.fun.(x)
    t1 = @timed y = sample(s; samplerate = samplerate, release = release)
    @info "Sampling:"
    @show t1.time, t1.bytes/1E6, t1.gctime, t1.compile_time, t1.recompile_time
    y = y ./ maximum(y) # rescale y
    t2 = @timed WAV.wavwrite(y, file, Fs = samplerate)
    @info "Writing file"
    @show t2.time, t2.bytes/1E6, t2.gctime, t2.compile_time, t2.recompile_time
    t3 = @timed play && WAV.wavplay(file)
    @info "Playing file"
    @show t3.time, t3.bytes/1E6, t3.gctime, t3.compile_time, t3.recompile_time
    file
end

## Sampling time dominates.
## Ideas to make it faster:
## Avoid computing all the zeros of the functions added.
## Can modeling toolkit help?


# ADSR envelope
"""
        adsr_env(t, d; A=0.1, D=0.1, S=0.9, R=0.1)
        t: time variable
        d: duration. Time when Release sets in
        A: attac. Time to reach 1 (in sec)
        D: decay. Time to reach S
        S: sustain. Fraction of loudness sustained
        R: Release. Time to dreach 0 after note end

If d < A+D, we keep as much as we can of A and truncate D

Example

```
harm_osc(t; phi=0) = sin(t*2pi + phi)
i4 = synthesizer(harm_osc, adsr_env)

```
"""
function adsr_env(t, d; A=0.1, D=0.1, S=0.9, R=0.1)
    if A+D > d
        A = min(A, d)
        D = A < d ? d - A : 0
        @debug @show A, D, d
    end
    D2 = A + D
    t <= 0     && return zero(A)
    t >= d + R && return zero(A)
    t <= A     && return t/A 
    t <= D2    && return -(1-S)*(A/(A-D2)-t/(A-D2)) + 1
    t >=d      && return S*((d+R)/R-t/R)
    return S
end

## TODO: AHR (attach, halflife, release). Exponential decay after attac.
## TODO: option to start sound at t=-A so support is [-A; d+R] rather than [0; d+R]. Then play also needs to start sampling a bit before 0.
## TODO: prasing: add emphasis on beat 1 (or others)
## TODO Groving: small changes in timint. See Music.jl I there is something

# MIDI player

"""
        A Tuning consists of the vector of scalings in an octave.
        It is called on a pitch and returns the corresponding frequency.
        The root pitch and frequency are given as keyword arguments

Example:
```
t4 = Tuning([1, 1.25, 1.5, 1.75])
t4(1, root_pitch=1, root_frequency=1)
# 1.0

t4.(1:9, root_pitch=1, root_frequency=1)
# 9-element Vector{Float64}:
#  1.0
#  1.25
#  1.5
#  1.75
#  2.0
#  2.5
#  3.0
#  3.5
#  4.0

tet12 = Tuning([(2^(1/12))^x for x in 0:(11)])
tet12(69)
# 440.0000000000001

```
"""
struct Tuning{T}
    scalings::Vector{T}
    # name::String
end 

import Base.length
length(t::Tuning) = length(t.scalings)

function (t::Tuning)(p; root_pitch = 60, root_frequency = 261.6255653005986)
    octave_length = length(t)
    pitch_diff = p - root_pitch
    scale_idx = mod(pitch_diff, octave_length) + 1
    scaling = t.scalings[scale_idx]
    octave = pitch_diff >=0 ? div(pitch_diff, octave_length) : div(pitch_diff, octave_length, RoundFromZero)
    freq = (root_frequency * scaling)*2.0^octave
    @debug "pitch=$p, octave=$octave, scale index=$scale_idx, scaling=$scaling, frequency=$freq"
    return freq
end

const tet12 = Tuning([(2^(1/12))^x for x in 0:(11)])

const justC = Tuning([1, 16//15, 9//8, 6//5, 5//4, 4//3, 45//32, 3//2, 8//5, 5//3, 16//9, 15//8]) # ref https://johncarlosbaez.wordpress.com/2025/12/26/the-mathematics-of-tuning-systems/ 

abstract type AbstractNote end
struct Note{T} <: AbstractNote
    pitch::Int
    loudness::Float32
    beats::T
end

note(n::Int; l=1, d=1) = Note(n,convert(Float32,l),d)
note(n::T; l=1., d=1) where T <: AbstractString = Note(MIDI.name_to_pitch(n), convert(Float32,l), d)

## TODO Chord as AbstractNote

## Now take instrument on note

(i::S where {S <: AbstractInstrument})(n::Note; tuning = tet12, bpm = 60) = i(tuning(n.pitch), n.beats * 60/bpm, n.loudness )

# Read a MIDI file
function note(n::MIDI.Note, tpq) # tpq = ticks per quarter. My beat is 1 for quarter
    Note(
        Int(n.pitch), # pitch
        Float32(n.velocity / 127), # loudness
        Float32(n.duration / tpq), # beats
    )
end

# Better: play a midi note directly:
function (i::S where {S <: AbstractInstrument})(n::MIDI.Note, t::Tuning, ms_per_tick)
    dilate(i(t(n.pitch), n.duration*ms_per_tick/1000, n.velocity/127), n.position*ms_per_tick/1000)
end

sound(n::MIDI.Note, instrument, tuning::Tuning, ms_per_tick) = instrument(n, tuning, ms_per_tick)

function sound(t::MIDI.MIDITrack, instrument, tuning::Tuning, ms_per_tick; notes = Inf)
    s = Sound{Float64}[]
    # Loop over tracks
    i = 1 ## TEMP
    @show t
    # Loop over notes
    for n in MIDI.getnotes(t)            
        # create Sound
        i > notes && break
        @show n, i
        push!(s, instrument(n,  tuning,  ms_per_tick))
        i += 1
    end
    sum(s)
end


function sound(m::MIDI.MIDIFile, instrument, tuning; notes = Inf) ## TODO: more instruments, handle time change events etc
    mspt = MIDI.ms_per_tick(m) # ms per tick needed for playing
    s = Sound{Float64}[]
    # Loop over tracks
    i = 1 ## TEMP
    for t in m.tracks # This is not what takes time, som no need to parallelize this.
        @show t
        length(MIDI.getnotes(t)) == 0 && continue
            push!(s, sound(t, instrument, tuning, mspt, notes = notes))
        # # Loop over notes
        # for n in MIDI.getnotes(t)            
        #     # create Sound
        #     i > notes && break
        #     @show n, i
        #     push!(s, instrument(n,  tuning,  mspt))
        #     i += 1
        # end
    end
    sum(s)
end


function play_midi(file, instrument, tuning::Tuning; notes = Inf)
    ## 1 instrument for all tracks or N instruments for N racks
    m1 = MIDI.readMIDIFile(file)
    @show m1
    # quantization can be done using MusicManipulations.segment or similar
    s1 = sound(m1, instrument, tuning; notes = notes)
    play_wav(s1)
end

# From https://juliamusic.github.io/JuliaMusic_documentation.jl/latest/midi/io/#MIDI-Events
# MIDI.SetTempoEvent — Type

# SetTempoEvent <: MetaEvent

# The SetTempoEvent sets the tempo of a MIDI sequence in terms of microseconds per quarter note.

# Fields:

#     dT::Int : Delta time in ticks.
#     metatype::UInt8 : Meta type byte of the event.
#     tempo::Int : The tempo in microseconds per quarter note.

# MIDI.TimeSignatureEvent — Type

# TimeSignatureEvent <: MetaEvent

# The TimeSignatureEvent contains the time signature of a MIDI sequence.

# Fields:

#     dT::Int : Delta time in ticks.
#     metatype::UInt8 : Meta type byte of the event.
#     numerator::Int : Numerator of the time signature.
#     denominator::Int : Denominator of the time signature.
#     clockticks::Int : MIDI clock ticks per click.
#     notated32nd_notes::Int : Number of 32nd notes per beat.

# bpm = MIDI.bpm(m1) # MIDI.bpm is wrong for lilypond produced midi file. Consider using qpm in stead!
# tpq = m1.tpq # ticks per quarter. Need to convert MIDI.Note to MusicalPlaying.Note
# TODO: MIDI.jl reports qpm == 60 (correct), but bpm == 80 on praeludium_1.midi

# Effects
## Linear effects can be applied per Sound.
## Non-linear effects are probably non-commutative.
## Remember option to keep some "dry".

