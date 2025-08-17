struct Instrument
    synth::Function ## 1-periodic
end

## sine(frequency; phase = 0, amplitude = 1) = Instrument(x -> amplitude * sin(2pi * frequency + phase))
sine = Instrument(x -> sin(2pi * x))

struct Instrument2
    oscillator::Function ## 1-periodic
    envelope::Function
end

"""
    adsr(attack=50, decay=0, sustain=1, release=100)

    Generates an ADSR envelope function.
    attack, decay and release are in ms.
    dedacy is in fraction of full ampltude (may be >1)
    Sound is extended by `release` ms.
"""
function adsr(attack=50, decay=0, sustain=1, release=100) 
    ## This should be able to go into sound_func or similar to give new function, and new t_end
    ## the current sound_func finding new t_end should be redone in terms of an envelope (where t_end depends on tone)
end
