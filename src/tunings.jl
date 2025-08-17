struct Tuning
  tuning::Function
  length::Int
  name::String
  names::Function
end 

#= Function:
from pitch to frequency.
Function based on TuningSystem
=#

"""
    TuningSystem{T}

Data structure for a tuning system.
A tuning system is defined by a vector of `scalings` of the type `T` (probably `<: Number`).
The scalings are frequency rations within the octave of the pitches of the tones in the octave.
It also includes `names` of each scaling.
In case of the 12 tone equal temperement, it could be the names of the notes: C, C#, D, D#, E, ..., B.
It also includes a name of the tuning (used for plotting etc).

Preferably use the constructor function [`tuning_system`](@ref ) to construct it.
"""
struct TuningSystem{T}
    steps::Int
    scalings::Vector{T}
    name::String
    names::Vector{String}
end

import Base.length
Base.length(t::TuningSystem) = length(t.scalings)

"""
     tuning_system(v::Vector{T}, [n::String], [s::Vector{String}]) where T <: Number -> TuningSystem

Construct a [`TuningSystem`](@ref).

## Arguments
- `v::Vector`: The vector of scaings defining the function.
- `n::String`: The name of the tuning system. Defaults to "tuning"
- `s::Vector{String}`: The names of the scalings. Defaults to `string.v()`

"""
tuning_system(l::Int,v::Vector{T}, n::String, s::Vector{String}) where T <: Number = TuningSystem(l,v,n,s)
tuning_system(v::Vector{T}, n::String, s::Vector{String}) where T <: Number = TuningSystem(length(v),v,n,s)
tuning_system(v::Vector{T}, n::String) where T <: Number = TuningSystem(length(v), v, n, string.(v))
tuning_system(v::Vector{T}) where T <: Number = TuningSystem(length(v), v, :tuning, string.(v))

function _equal_tempered(n) ## n TET n Tone Equal Temperement. n EDO Even Divisions of Octave
    scalings = [(2^(1/n))^x for x in 0:(n-1)]
    if n == 12
        names = ["C","C#","D", "D#", "E", "F", "F#", "G", "G#", "A", "A#","B"]
    else
        names = string.(Int.(round.(cents.(scalings))))
    end
    tuning_system(n, scalings, string(n,"TET"), names)
end

function _geometric_tuning(ratio, steps; name=missing)
    if ismissing(name)
        name = string(steps,"step",ratio)
    end
    tuning_system(sort(pitch_class.([(ratio)^x for x in 0:(steps-1)])), name)
end

_just13 = tuning_system(sort([1, 16//15, 9//8, 6//5, 5//4, 4//3, 64//45, 45//32, 3//2, 8//5, 5//3, 16//9, 15//8]), "Just13")
_just = tuning_system([1, 16//15, 9//8, 6//5, 5//4, 4//3,  45//32, 3//2, 8//5, 5//3, 16//9, 15//8], "Just")

"""
  mk_tuning: Generate Tuning based on TuningSystem
"""
function mk_tuning(tuning::TuningSystem; root_pitch = 60, root_frequency = 261.6255653005986)
  function tuning_function(pitch) # pitch
    octave_length = length(tuning)
    pitch_diff = pitch - root_pitch
    scale_idx = mod(pitch_diff, octave_length) + 1    
    scaling = tuning.scalings[scale_idx]
    octave = pitch_diff >=0 ? div(pitch_diff, octave_length) : div(pitch_diff, octave_length, RoundFromZero) 
    freq = (root_frequency * scaling)*2.0^octave
    @debug "pitch=$(n.pitch), octave=$octave, scale index=$scale_idx, scaling=$scaling, frequency=$freq"
    freq
  end
  function names_function(pitch)
    octave_length = length(tuning)
    pitch_diff = pitch - root_pitch
    scale_idx = mod(pitch_diff, octave_length) + 1    
    tuning.names[scale_idx]    
  end
  Tuning(tuning_function, length(tuning), tuning.name, names_function)
end


"""
    equal_tempered(n)

Constructs an equal tempered tuning of length `n`.

If the length `n` is 12, the names of the scalings are set to the standard names of the notes: "C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B".

The `scalings` of and equal tempered scale of length `n` divides the octave evenly on a log scale.
This means the ratio between successive scalings are `2^(1/n)`.

So the vector of scalings is:

``` julia
    scalings = [(2^(1/n))^x for x in 0:(n-1)]
```

"""
equal_tempered(n) = mk_tuning(_equal_tempered(n))
tet12 = equal_tempered(12)
just_intonation = mk_tuning(_just)
