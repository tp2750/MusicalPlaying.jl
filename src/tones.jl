struct Tone
  frequency::Float32
  note::Union{Note, Missing}
  tuning::Union{Tuning, Missing}
end

function tone(note::Note; tuning=tet12)
  Tone(tuning.tuning(note.pitch), note, tuning)
end
