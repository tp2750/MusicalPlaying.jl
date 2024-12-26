struct Instrument
    synth::Function ## 1-periodic
end

## sine(frequency; phase = 0, amplitude = 1) = Instrument(x -> amplitude * sin(2pi * frequency + phase))
sine = Instrument(x -> sin(2pi * x))
