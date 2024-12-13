using MusicalPlaying
using Documenter

DocMeta.setdocmeta!(MusicalPlaying, :DocTestSetup, :(using MusicalPlaying); recursive=true)

makedocs(;
    modules=[MusicalPlaying],
    authors="Thomas Poulsen <ta.poulsen@gmail.com> and contributors",
    sitename="MusicalPlaying.jl",
    format=Documenter.HTML(;
        canonical="https://tp2750.github.io/MusicalPlaying.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/tp2750/MusicalPlaying.jl",
    devbranch="main",
)
