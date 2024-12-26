struct Tone{T <: AbstractNote}
  frequency::Vector{Float32}
  note::Union{T, Missing}
  tuning::Union{Tuning, Missing}
end

function tone(note::Note; tuning=tet12)
  Tone(convert.(Float32,[tuning.tuning(note.pitch)]), note, tuning)
end

function tone(chord::Chord; tuning=tet12)
  Tone(convert.(Float32,tuning.tuning.(chord.pitch)), chord, tuning)
end

