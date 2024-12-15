var documenterSearchIndex = {"docs":
[{"location":"notes/","page":"Notes","title":"Notes","text":"CurrentModule = MusicalPlaying","category":"page"},{"location":"notes/#Notes","page":"Notes","title":"Notes","text":"","category":"section"},{"location":"notes/","page":"Notes","title":"Notes","text":"A Note is a type meant to encode the abstract note:","category":"page"},{"location":"notes/","page":"Notes","title":"Notes","text":"pitch::Int: the height of the tone\nloudness::Float32: the volume of the tone\nduration::Float32: the length of the tone","category":"page"},{"location":"notes/","page":"Notes","title":"Notes","text":"The pitch is just an integer, and not a frequency. The frequency is assigned by a TuningSystem. This means that the same melody (series of notes) can easily be analyzed in different tunings by changing the tuning.","category":"page"},{"location":"notes/","page":"Notes","title":"Notes","text":"We also define a Chord which is a vector of notes, that all have the same duration, but may differ in loudness.","category":"page"},{"location":"notes/","page":"Notes","title":"Notes","text":"We define an AbstractNote covering Note and Chord, and define play and save methods on the AbstractNote. ","category":"page"},{"location":"notes/#Playing-Notes","page":"Notes","title":"Playing Notes","text":"","category":"section"},{"location":"notes/","page":"Notes","title":"Notes","text":"We have methods for directly playing notes: play_wav_direct.  This will take:","category":"page"},{"location":"notes/","page":"Notes","title":"Notes","text":"a Note and play the note using a standard equal temperemt\na Chord and play the chord\na Vector{N} where N <: AbstractNote and play a sequence of Notes or Chords","category":"page"},{"location":"notes/","page":"Notes","title":"Notes","text":"Here are some examples:","category":"page"},{"location":"notes/","page":"Notes","title":"Notes","text":"using MusicalPlaying\nplay_wav_direct(\"A\")\nplay_wav_direct(chord([\"C\", \"E\", \"G\"]))\nplay_wav_direct(note.([\"C\", \"E\", \"G\"]))\nplay_wav_direct([chord([\"C\", \"E\", \"G\"]), chord([\"F\",\"A\",\"C\"]), chord([\"G\", \"B\", \"D\"]), chord([\"C\", \"E\", \"G\"])])","category":"page"},{"location":"notes/","page":"Notes","title":"Notes","text":"The play_wav_direct methods work by writeing and reading a WAV-file.  We (will also) have play_portaudio methods that use PortAudio.jl and SampleSignals.jl to play a stream.  This is more efficient for long pieces. But the play_wav_diret is simple and very robust for studiyng short phrases.","category":"page"},{"location":"","page":"Home","title":"Home","text":"CurrentModule = MusicalPlaying","category":"page"},{"location":"#MusicalPlaying","page":"Home","title":"MusicalPlaying","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Documentation for MusicalPlaying.","category":"page"},{"location":"","page":"Home","title":"Home","text":"","category":"page"},{"location":"","page":"Home","title":"Home","text":"Modules = [MusicalPlaying]","category":"page"},{"location":"#MusicalPlaying.AbstractNote","page":"Home","title":"MusicalPlaying.AbstractNote","text":"    AbstractNote covers Note and Chord\n\n\n\n\n\n","category":"type"},{"location":"#MusicalPlaying.Note","page":"Home","title":"MusicalPlaying.Note","text":"    `Note(pitch::Int, duration::Float32, volume::Float32)`\n    `pitch` is the pitch number. MIDI sets pitch 69 to A4 and 440 Hz. This can be modulated by a Tuning.\n    `loudness` is relative volume. A note of loudness 2 has twice the amplitued as one of loudness 1.\n    `duration` is the duration in beats. Typically a quater note has a duration of 1, and a half note a duration of 2.\n\n\n\n\n\n","category":"type"}]
}