%%raw("import './Playlist.css'")

type song = {
  name: string,
  url: string,
  artist: string,
}

type songs = {songs: array<song>}

@react.component
let make = (
  ~songs: array<song>,
  ~selectSong: (song, int) => unit,
  ~selectedSong: int,
  ~shuffler: unit => unit,
) => {
  <div className="songsList">
    <h3> {React.string("Songs:")} </h3>
    <ul className="playlist">
      {songs
      ->Belt.Array.mapWithIndex((idx, song) => {
        <li key={Belt.Int.toString(idx)}>
          <a
            key={Belt.Int.toString(idx)}
            className={`songItem ++ ${idx == selectedSong ? "active" : ""}`}
            onClick={_ => selectSong(song, idx)}>
            {React.string(`${song.name} - ${song.artist}`)}
          </a>
        </li>
      })
      ->React.array}
    </ul>
    <button className="shuffleButton" onClick={_ => shuffler()}> {React.string("Shuffle")} </button>
  </div>
}
