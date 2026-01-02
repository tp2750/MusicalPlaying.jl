```@meta
CurrentModule = MusicalPlaying
```
# Synthesizers

Synthesizers are AbstractInstruments that are defined by an pre-oscillator and a pre-envelope.

A pre-oscillator takes a frequency as argument and returns a function with that frequency as the main harmonic.
A pre-envelope takes a duration and a loundness, and plays the sound for that duration at that loundness.

To make things simpler, the constructor `synthesizer` can be called with an oscillator and and envelope as arguments.
An oscilator is a 1-periodic funciton with amplitude about 1.
An envelope is a function that is 0 outside [0; 1] and maximum of about 1.

## Example using `synthesizer()`
``` julia
using MusicalPlaying
using Plots
using WAV

harm_osc(t; phi=0) = sin(t*2pi + phi)

function tri(t, d=1; t1=.5)
    t = t/d
    t <= 0 && return 0
    t >= 1 && return 0
    t <= t1 && return t/t1
    return (1/(1-t1)-t/(1-t1))
end

i2 = synthesizer(harm_osc, tri_env)
i3 = synthesizer(harm_osc, tri_env; env_kw = (;t1=.25))

plot(
        plot(i3.oscillator(10), -1, 3, label="osc"),
        plot(i3.envelope(2,1), -1, 3, label = "env"),
        plot(i3(10, 2, 1).fun, -1, 3, label = "sound"),
        layout = (3,1), 
)
```        

Note, that this envelope streches, so longer notes start slower.

### ADSR

Here's an example of an ADSR envelope.
Note the re-scaling in the second example.

``` julia
using MusicalPlaying
using Plots
using WAV

harm_osc(t; phi=0) = sin(t*2pi + phi)
i4 = synthesizer(harm_osc, adsr_env)
i5 = synthesizer(harm_osc, adsr_env; env_kw = (;  A=.5, D=.5, S=0.5, R=0.5))
i6 = synthesizer(harm_osc, adsr_env; env_kw = (;  A=.5, D=2, S=.5, R=0.5))

plot(
        plot(i4(100, 2, 1).fun, -1, 3, label = "sound 1"),
        plot(i5(100, 2, 1).fun, -1, 3, label = "sound 2"),
        plot(i6(100, 2, 1).fun, -1, 3, label = "sound 3"),
        layout = (3,1), 
)
play_wav(i4([400, 500, 600], 2, 1))
```

## Example using `Synthesizer`

``` julia
using MusicalPlaying
using Plots
using WAV

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

# Play a midi file

Currently performance of playing a MIDI file is terrible!

``` julia
using MusicalPlaying
using WAV
import MIDI ## MIDI.Note conflicts with MusicalPlaying.Note

i4 = synthesizer(harm_osc, adsr_env)
m1 = MIDI.readMIDIFile("midi/praeludium_1.midi")
# s1 = sound(m1, i4, justC); # 0.01 sec
# play_wav(s1)

mspt = MIDI.ms_per_tick(m1) # 384

s3 = sound(m1.tracks[3], i4, justC, mspt; notes = 100) ; # first notes # 0.15 s per note. O3: 23 sec compile for 34 sec play
play_wav(s3)

## First section. Sample time 10s, playing time: 17s
play_wav(
    sound(m1.tracks[2], i4, justC, mspt; notes = 14) +
    sound(m1.tracks[3], i4, justC, mspt; notes = 48) +
    sound(m1.tracks[4], i4, justC, mspt; notes = 16) 
)

```

It takes some time to compute the full sound: 9 sec for this 17 sec sound.
TODO: parallelize over tracks and instruments to speed up rendering the full sound.

TODO: 
For playing, we can start playing before we have rendered everything.
This should be doable using SampledSignals.jl
