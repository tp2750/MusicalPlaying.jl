module MusicalPlaying

import MIDI
import WAV

include("notes.jl")
export Note, note, play_wav_direct, Chord, chord, Melody

include("tunings.jl")
export tet12, equal_tempered, just_intonation

include("tones.jl")
export tone
end
