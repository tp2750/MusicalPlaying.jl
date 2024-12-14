# MusicalPlaying.jl

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://tp2750.github.io/MusicalPlaying.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://tp2750.github.io/MusicalPlaying.jl/dev/)
[![Build Status](https://github.com/tp2750/MusicalPlaying.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/tp2750/MusicalPlaying.jl/actions/workflows/CI.yml?query=branch%3Amain)

MusicalPlaying.jl is a package for playing (with) music.

It grew out of [TuningSystems.jl]() ([presented on JuliaCon2024]()) to have a more complete and better structured package.
It does have some overlap with `MusicTheory.jl` and `MIDI.jl` from [JuliaMusic]. 
In time, this may be resolved, but for now, I focus on writing the package, as I find most logical.

I plan to cover:

- [X] Playing simple notes, chords and melodies.
- [ ] Explore different Tuning Systems, in particular Just Intonation
- [ ] Represent Scores of several voices
- [ ] Use DataFrames to view Scores as in a Tracker
- [ ] Plot notes, chords and scores in an "isometric" form more natural that the classical scores
- [ ] Possibly generate traditional Piano-roll plots
- [ ] Define basit types to represent note, tone, sound
- [ ] Explore sound synthesis
- [ ] Act as a very simple MIDI player
- [ ] Parse (simple) Lilypond syntax

On the synthesis side, I want to keep working on functions as long as possible, and only sample just before rendering to WAV.

