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
    let make = (~songs: array<song>, ~selectSong: (song) => unit, ~selectedSong: option<song>) => {

    let getSongSelected = () : string => {
        switch(selectedSong){
            | Some(selectedSong) => selectedSong.name
            | None => ""
        }
    }

    <div className="songsList">
        <h3>{React.string("Songs:")}</h3>
        {
            songs->Belt.Array.map((song) => {
                <a key={song.name} 
                    className={`songItem ++ ${song.name == getSongSelected() ? "active" : ""}`} 
                    onClick={_ => selectSong(song)}> 
                    { React.string(`${song.name} - ${song.artist}`) } 
                </a>
                }
            ) -> React.array
        }
    </div>
}