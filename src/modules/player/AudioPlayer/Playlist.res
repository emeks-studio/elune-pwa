%%raw("import './Playlist.css'")


type song = {
    name: string,
    url: string,
    artist: string
}

type songs = {
    songs: array<song>
}

@react.component
    let make = (~songs: array<song>, ~selectSong: (song, int) => unit, ~selectedSong: int) => {

    <div className="songsList">
        <h3>{React.string("Songs:")}</h3>
        {
            songs->Belt.Array.mapWithIndex((idx, song) => {
                <a key={Belt.Int.toString(idx)}
                    className={`songItem ++ ${idx == selectedSong ? "active" : ""}`} 
                    onClick={_ => selectSong(song, idx)}> 
                    { React.string(`${song.name} - ${song.artist}`) } 
                </a>
                }
            ) -> React.array
        }
    </div>
}