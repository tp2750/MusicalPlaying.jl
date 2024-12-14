# Notes
A `Note` is a type meant to encode the abstract note:

* `pitch::Int`: the height of the tone
* `loudness::Float32`: the volume of the tone
* `duration::Float32`: the length of the tone

The pitch is just an integer, and not a frequency.
The frequency is assigned by a TuningSystem.
This means that the same melody (series of notes) can easily be analyzed in different tunings by changing the tuning.

We also define a `Chord` which is a vector of notes, that all have the same `duration`, but may differ in `loudness`.

We define an `AbstractNote` covering `Note` and `Chord`, and define `play` and `save` methods on the `AbstractNote`. 

## Playing Notes
We have methods for directly playing notes: `play_wav_direct`. 
This will take:

* a `Note` and play the note using a standard equal temperemt
* a `Chord` and play the chord
* a `Vector{N} where N <: AbstractNote` and play a sequence of Notes or Chords

Here are some examples:

``` @example
play_wav_direct("A")
play_wav_direct(chord(["C", "E", "G"]))
play_wav_direct(["C", "E", "G"])
play_wav_direct([chord(["C", "E", "G"]), chord(["F","A","C"]), chord(["G", "B", "D"]), chord(["C", "E", "G"])])
```

The `play_wav_direct` methods work by writeing and reading a WAV-file. 
We (will also) have `play_portaudio` methods that use `PortAudio.jl` and `SampleSignals.jl` to play a stream. 
This is more efficient for long pieces.
But the `play_wav_diret` is simple and very robust for studiyng short phrases.

