%%raw("import './App.css'")

@react.component
let make = () => {
  let (selectedSong, setSelectedSong) = React.useState(_ => None)

  let pickSong = (song) => {
    setSelectedSong(_ => Some(song))
  } 

  <div className="App">
      <header className="App-header">
        <p>{React.string("Elune PWA")}</p>
      </header>
      <div>
        <PlayList selectSong={pickSong} selectedSong={selectedSong}/>
        <AudioPlayer songToPlay={selectedSong}/>
      </div>
  </div>
};
