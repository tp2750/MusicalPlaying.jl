```@meta
CurrentModule = MusicalPlaying
```

# MusicalPlaying.jl

[MusicalPlaying](https://github.com/tp2750/MusicalPlaying.jl) is my Julia package for playing (with) music.

It grew out of [TuningSystems.jl](https://github.com/tp2750/TuningSystems.jl) [presented](https://youtu.be/6Te9rThZaa4?list=PLP8iPy9hna6R5gUZLbSZCZTGJ0uncLBfi&t=11909) on [JuliaCon2024](https://pretalx.com/juliacon2024/speaker/UPFEMA/) to have a more complete and better structured package. 
It has some overlap with [MusicTheory.jl](https://github.com/JuliaMusic/MusicTheory.jl) and [MIDI.jl](https://github.com/JuliaMusic/MIDI.jl) from [JuliaMusic](https://github.com/JuliaMusic). 
In time, this may be resolved, but for now, I focus on writing the package, as I find most logical.

I plan to cover:

- [X] Playing simple notes, chords and melodies.
- [ ] Explore different Tuning Systems, in particular Just Intonation
- [ ] Represent Scores of several voices
- [ ] Use DataFrames to view Scores as in a Tracker
- [ ] Plot notes, chords and scores in an "isometric" form more natural that the classical scores
- [ ] Possibly generate traditional Piano-roll plots
- [ ] Define basic types to represent note, tone, sound
- [ ] Explore sound synthesis
- [ ] Act as a very simple MIDI player
- [ ] Parse (simple) Lilypond syntax

On the synthesis side, I want to keep working on functions as long as possible, and only sample just before rendering to WAV.

# Basic Data Types
The basic data sctructures are similar, but different from both [MIDI.jl](https://github.com/JuliaMusic/MIDI.jl) and [MusicTheory.jl](https://github.com/JuliaMusic/MusicTheory.jl).

## Note
The [`Note`](@ref) data type descries an abstract note, as we see in a score:

* The "pictch": note height. An integer between 0 and 127 as the MIDI note. Not directly a frequency, we get that through the "TunigSystem".
* The "loudness": relative volume. Not directly amplitude. That comes in a mastering step just before sampling. Defaults to 1. Perhaps "forte" is 2 and "piano" as 0.5.
* The "duration": relative note length. 1 is a "beat", so a duration of 1 sounds for 1 sec if the tempo is 60 bpm. Typically, a auarter note has a dutration of 1, and a half note a duration of 2.

## Chord
a `Chord` is a sequence (Vector) of `Note`s with the same `duration` (but possibly different `loudness`) that are played together at the same time.

## AbstractNote
[`Note`](@ref) and [`Chord`](@ref) are the instances of `AbstractNote`.

## Melody (TODO)
A `Melody` is a sequence (Vector) of `Note`s and `Chords` that are played in succession.

## Tone (TODO)
The tone combines a `Note` or `Chrod` with a `Tuning` to assign frequency to the pitch.
This was the objective of [TuningSystems.jl](https://github.com/tp2750/TuningSystems.jl).

The slots of `Tone` are

* frequency: The frequency in Hz.
* note: remember the AbstractNote this comes from
* tuning: rember the Tuning used




