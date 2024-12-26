import MIDI
import WAV

"""
        AbstractNote covers Note and Chord
"""
abstract type AbstractNote end

"""
        `Note(pitch::Int, duration::Float32, volume::Float32)`
        `pitch` is the pitch number. MIDI sets pitch 69 to A4 and 440 Hz. This can be modulated by a Tuning.
        `loudness` is relative volume. A note of loudness 2 has twice the amplitued as one of loudness 1.
        `duration` is the duration in beats. Typically a quater note has a duration of 1, and a half note a duration of 2.
"""
struct Note <: AbstractNote
    pitch::Int
    loudness::Float32
    duration::Float32
end
note(n::Int; l=1, d=1) = Note(n,l,d)
note(n::T; l=1, d=1) where T <: AbstractString = Note(MIDI.name_to_pitch(n), l, d)

struct Chord <: AbstractNote ## TODO @assert length(pitch) == length(loudness)
    pitch::Vector{Int}
    loudness::Vector{Float32}
    duration::Float32
    # @assert length(pitch) == length(loudness)
    # new(pitch, loudness, duration)
end

function chord(ns::Vector{Note})
    Chord(map(x -> x.pitch, ns),
          map(x -> x.loudness, ns),
          only(unique(map(x -> x.duration, ns)))
          )
end

chord(ns::Vector{String}; l = 1/length(ns), d = 1) = chord(note.(ns; l, d))

struct Melody{T <: AbstractNote}
   notes::Vector{T}
end
import Base.length
length(m::Melody) = length(m.notes)

function sample_wav_direct(n::Note; bpm=60, samplerate = 44100)
    freq = MIDI.pitch_to_hz(n.pitch)
    x = 0:1/samplerate:prevfloat(n.duration*60/bpm)
    y = n.loudness * sin.(2pi * freq * x )
    y
end

function sample_wav_direct(c::Chord; bpm=60, samplerate = 44100, file=tempname())
    ns = map(x -> note(x[1], l = x[2], d = c.duration), zip(c.pitch, c.loudness))
    ys = sample_wav_direct.(ns; bpm, samplerate)
    y = sum(ys)
    y
end

function save_wav_direct(n::AbstractNote; bpm=60, samplerate = 44100, file=tempname())
    y = sample_wav_direct(n; bpm, samplerate)
    WAV.wavwrite(y, file, Fs=samplerate)
    file
end

function save_wav_direct(v::Vector{N}; bpm=60, samplerate = 44100, file=tempname()) where N <: AbstractNote
    ys = sample_wav_direct.(v; bpm, samplerate)
    y = reduce(vcat, ys)
    WAV.wavwrite(y, file, Fs=samplerate)
    file
end

save_wav_direct(s::String; bpm=60, samplerate = 44100, file=tempname()) = save_wav_direct(note(s); bpm, samplerate, file)

function play_wav_direct(n; bpm=60, samplerate = 44100, file=tempname())
    save_wav_direct(n; bpm, samplerate, file)
    WAV.wavplay(file)
end

function save_wav_direct(m::Melody; bpm=60, samplerate = 44100, file=tempname())
    save_wav_direct(m.notes; bpm, samplerate, file)
end
function sample_wav_direct(m::Melody; bpm=60, samplerate = 44100)
    sample_wav_direct.(m.notes; bpm, samplerate)
end
