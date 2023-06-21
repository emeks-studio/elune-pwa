%%raw("import './AudioPlayer.css'")

@scope("JSON") @val external parseIntoMyData: string => Playlist.songs = "parse"
@module("../../../assets/jesus-dancing.gif") external jesus: string = "default"

module AudioHtmlBindings = {
  @send external pause: Dom.element => unit = "pause"
  @send external play: Dom.element => unit = "play"
  @set external setCurrentTime: (Dom.element, int) => unit = "currentTime"
  @get external currentTime: Dom.element => int = "currentTime"
  @get external duration: Dom.element => int = "duration"
  @send external addEventListener: (Dom.element, string, unit => unit) => unit = "addEventListener"
  @send
  external removeEventListener: (Dom.element, string, unit => unit) => unit = "removeEventListener"
}

let getCurrent = (audioRef: React.ref<Js.Nullable.t<Dom.element>>): option<Dom.element> => {
  audioRef.current->Js.Nullable.toOption
}

let formatTime = (secs: int): string => {
  let minutes: int = secs / 60
  let seconds: int = mod(secs, 60) / 1

  let formattedMinutes = Belt.Int.toString(minutes)
  let formattedSeconds = Belt.Int.toString(seconds)

  if formattedSeconds->String.length < 2 {
    formattedMinutes ++ ":0" ++ formattedSeconds
  } else {
    formattedMinutes ++ ":" ++ formattedSeconds
  }
}

module PlayListSource = {
  let getSongs = (): array<Playlist.song> => {
    let playerSongs: Playlist.songs = parseIntoMyData(Songs.songs)
    playerSongs.songs
  }
}

module MysticImage = {
  @react.component
  let make = (~loading: bool, ~playing: bool) => {
    <div>
      {switch (loading, playing) {
      | (true, false) => <img src="https://media.tenor.com/jfmI0j5FcpAAAAAM/loading-wtf.gif" />
      | (false, true) => <img src={jesus} />
      | _ => React.null
      }}
    </div>
  }
}

module AudioControls = {
  @react.component
  let make = (~audioRef: React.ref<Js.Nullable.t<Dom.element>>, ~song: Playlist.song) => {
    let (isPlaying, setIsPlaying) = React.useState(_ => false)
    let (pctPlayed, setPctPlayed) = React.useState(_ => "0")
    let (duration, setDuration) = React.useState(_ => "00:00")
    let (timer, setTimer) = React.useState(_ => "00:00")
    let (waiting, setWaiting) = React.useState(_ => false)

    let pauseAudio = _ => {
      audioRef
      ->getCurrent
      ->Belt.Option.forEach(a => {
        a->AudioHtmlBindings.pause
        setIsPlaying(_prev => false)
      })
    }

    let playAudio = _ => {
      // Js.Console.log2("playAudio clicked", audioRef.current->Js.Nullable.toOption)
      audioRef
      ->getCurrent
      ->Belt.Option.forEach(a => {
        a->AudioHtmlBindings.play
        setIsPlaying(_prev => true)
      })
    }

    let stopAudio = _ => {
      audioRef
      ->getCurrent
      ->Belt.Option.forEach(a => {
        a->AudioHtmlBindings.pause
        AudioHtmlBindings.setCurrentTime(a, 0)
      })
      setIsPlaying(_prev => false)
      setPctPlayed(_prev => "0")
      setTimer(_prev => "00:00")
    }

    React.useEffect1(() => {
      setWaiting(_ => true)
      let handleTimeUpdate = (a: Dom.element) => {
        let updateTime = a->AudioHtmlBindings.currentTime * 100 / a->AudioHtmlBindings.duration
        setPctPlayed(_ => updateTime->Belt.Int.toString)
        setTimer(_ => a->AudioHtmlBindings.currentTime->formatTime)
      }

      let getDuration = () => {
        setWaiting(_ => false)
        audioRef
        ->getCurrent
        ->Belt.Option.forEach(a => setDuration(_ => a->AudioHtmlBindings.duration->formatTime))
      }

      let cb = () => audioRef->getCurrent->Belt.Option.forEach(a => handleTimeUpdate(a))

      let cleanUp = () =>
        audioRef
        ->getCurrent
        ->Belt.Option.forEach(a => AudioHtmlBindings.removeEventListener(a, "timeupdate", cb))
      audioRef
      ->getCurrent
      ->Belt.Option.forEach(a =>
        AudioHtmlBindings.removeEventListener(a, "loadedmetadata", getDuration)
      )

      audioRef
      ->getCurrent
      ->Belt.Option.forEach(a => AudioHtmlBindings.addEventListener(a, "timeupdate", cb))
      audioRef
      ->getCurrent
      ->Belt.Option.forEach(a =>
        AudioHtmlBindings.addEventListener(a, "loadedmetadata", getDuration)
      )
      setIsPlaying(_ => false)
      Some(cleanUp)
    }, [song])

    <div>
      <div>
        <div className="trackInfo">
          {React.string(`Now Playing: ${song.name} by: ${song.artist}`)}
        </div>
        <div className="progressReproduction">
          <div className="progressTimer"> {React.string(timer)} </div>
          <progress value={pctPlayed} max="100" />
          <div className="progressTimer"> {React.string(duration)} </div>
        </div>
      </div>
      <div className="Playercontrols">
        <button onClick={stopAudio}> {React.string("Stop")} </button>
        {switch isPlaying {
        | true => <button onClick={pauseAudio}> {React.string("Pause")} </button>
        | false => <button onClick={playAudio}> {React.string("Play")} </button>
        }}
        <MysticImage loading={waiting} playing={isPlaying}/>
      </div>
    </div>
  }
}

module AudioTrack = {
  @react.component
  let make = (~audioRef: ReactDOM.domRef, ~trackUrl: string) => {
    <audio preload="metadata" src=trackUrl ref=audioRef />
  }
}

@react.component
let make = () => {
  let (songs: array<Playlist.song>, setSongs) = React.useState(_prev => [])
  let (selectedSong, setSelectedSong) = React.useState(_ => None)
  let audioRef = React.useRef(Js.Nullable.null)

  React.useEffect0(() => {
    let playListSongs = PlayListSource.getSongs()
    setSongs(_prev => playListSongs)
    Some(() => setSongs(_prev => []))
  })

  let pickSong = song => {
    setSelectedSong(_ => Some(song))
  }

  <div>
    <Playlist songs={songs} selectSong={pickSong} selectedSong={selectedSong} />
    {switch selectedSong {
    | Some(songSelected) =>
      <div>
        <AudioTrack audioRef={ReactDOM.Ref.domRef(audioRef)} trackUrl={songSelected.url} />
        <AudioControls audioRef song={songSelected} />
      </div>
    | None => <div />
    }}
  </div>
}
