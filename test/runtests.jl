using MusicalPlaying
using Test

@testset "MusicalPlaying.jl" verbose = true begin
    @testset "notes.jl" begin
        @test MusicalPlaying.sample_wav_direct(note("A"); bpm=200, samplerate = 25) == [0.0, -0.5877852522924811, 0.9510565162951596, -0.9510565162951575, 0.587785252292441, 3.52896351958146e-14, -0.5877852522924522, 0.9510565162951619]
        @test MusicalPlaying.sample_wav_direct(chord(["C", "E", "G"]); bpm=200, samplerate = 25) == [0.0, 0.23167617587241696, 1.0745395930224104, 0.5173743742472834, -2.7497528639316835, 1.031974063328255, 0.14773056424284964, 0.9600050763242114]
    end

end
