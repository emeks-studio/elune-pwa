%%raw("import './PlayList.css'")
open ReactEvent;

type song = {
    name: string,
    url: string,
    artist: string
}

type songs = {
    songs: array<song>
}

@scope("JSON") @val external parseIntoMyData: string => songs = "parse"

module PlayListSource = {
    let getSongs = () => {
        let playerSongs = parseIntoMyData(Songs.songs)
        playerSongs.songs
    };
};

@react.component
    let make = (~selectSong) => {
    let (songs: array<song>, setSongs) = React.useState( _prev => [])

    React.useEffect0(() => {
        let playListSongs = PlayListSource.getSongs()
        setSongs(_prev => playListSongs)
        Some(() => setSongs(_prev => []))
    })

    <div className="songsList">
        <h3>{React.string("Songs:")}</h3>
        {
            songs->Belt.Array.map((song) => {
                <a key={song.name} className="songItem" onClick={_ => selectSong(song)}> 
                    { React.string(`${song.name} - ${song.artist}`) } 
                </a>
                }
            ) -> React.array
        }
    </div>
}
