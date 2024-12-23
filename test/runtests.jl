using MusicalPlaying
using Test

@testset "MusicalPlaying.jl" verbose = true begin
    @testset "notes.jl" begin
        @test MusicalPlaying.sample_wav_direct(note("A"); bpm=200, samplerate = 25) == [0.0, -0.5877852522924811, 0.9510565162951596, -0.9510565162951575, 0.587785252292441, 3.52896351958146e-14, -0.5877852522924522, 0.9510565162951619]
        @test MusicalPlaying.sample_wav_direct(chord(["C", "E", "G"]); bpm=200, samplerate = 25) == [0.0, 0.23167617587241696, 1.0745395930224104, 0.5173743742472834, -2.7497528639316835, 1.031974063328255, 0.14773056424284964, 0.9600050763242114]
        @test MusicalPlaying.sample_wav_direct(Melody(note.(["C","E","G"])); bpm=60, samplerate=4) == [
            [0.0, 0.5548316922637009, -0.9231984514960555, 0.9813015040347344],
            [0.0, 0.5522262552552144, -0.9207757475006034, 0.9830647040517729],
            [0.0, -0.007169081692236633, -0.014337794919535263, -0.02150577123578199]
        ]
    end

end
