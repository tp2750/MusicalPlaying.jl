struct Sound
    func::Function
    tone::Vector{Tone}
    start_t::Float32 # start time in secondes
    end_t::Float32 # end time in seconds
end


function sound(t::Tone, i::Instrument; bpm = 60, t_start = 0)
    i.synth(t, bpm, t_start)
end


function sound(m::Melody, i::Instrument; bpm=60, tuning=tet12)
    sounds = Sound[]
    funcs = Function[]
    tones = Tone[]
    local t_end
    t_start = 0.
        for note in m.notes
            t = tone(note; tuning)
            push!(sounds, i.synth(t, bpm, t_start))
            t_start = t_start + note.duration*60/bpm
        end
    f(t) = sum([s.func(t) for s in sounds])
    Sound(f, tones, 0., sounds[end].end_t)
end

function sample(s::Sound; samplerate = 44100)
    seconds = s.end_t - s.start_t
    x = 0:1/samplerate:prevfloat(seconds)
    y = s.func.(x)
    y
end



function play_wav(s::Sound; samplerate = 44100, file = tempname(), play = true)
    seconds = s.end_t - s.start_t
    x = 0:1/samplerate:prevfloat(seconds)
    y = s.func.(x)
    WAV.wavwrite(y, file, Fs = samplerate)
    play && WAV.wavplay(file)
    file
end

import Base.(+)
function +(a::A,b::B) where {A <: Function , B <: Function}
    x -> a(x) + b(x)
end
