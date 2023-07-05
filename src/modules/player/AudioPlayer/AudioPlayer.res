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
  let make = (
    ~audioRef: React.ref<Js.Nullable.t<Dom.element>>,
    ~song: Playlist.song,
    ~nextSong: unit => unit,
    ~prevSong: unit => unit,
  ) => {
    let (isPlaying, setIsPlaying) = React.useState(_ => false)
    let (pctPlayed, setPctPlayed) = React.useState(_ => "0")
    let (duration, setDuration) = React.useState(_ => "00:00")
    let (timer, setTimer) = React.useState(_ => "00:00")
    let (waiting, setWaiting) = React.useState(_ => false)
    let (isReady, setIsReady) = React.useState(_ => false)

    let pauseAudio = (_): unit => {
      audioRef
      ->getCurrent
      ->Belt.Option.forEach(a => {
        a->AudioHtmlBindings.pause
        setIsPlaying(_prev => false)
      })
    }

    let playAudio = (_): unit => {
      if isReady {
        audioRef
        ->getCurrent
        ->Belt.Option.forEach(a => {
          a->AudioHtmlBindings.play
          setIsPlaying(_prev => true)
        })
      }
    }

    let resetSong = (): unit => {
      setIsPlaying(_prev => false)
      setPctPlayed(_prev => "0")
      setTimer(_prev => "00:00")
    }

    let stopAudio = (_): unit => {
      audioRef
      ->getCurrent
      ->Belt.Option.forEach(a => {
        a->AudioHtmlBindings.pause
        AudioHtmlBindings.setCurrentTime(a, 0)
      })
      resetSong()
    }

    let nextAudio = (_): unit => {
      nextSong()
      stopAudio()
    }

    React.useEffect1(() => {
      if isReady {
        playAudio()
      }
      Some(() => ())
    }, [isReady])

    let prevAudio = (_): unit => {
      prevSong()
      stopAudio()
    }

    React.useEffect1(() => {
      audioRef
      ->getCurrent
      ->Belt.Option.forEach(a =>
        AudioHtmlBindings.addEventListener(a, "canplay", () => setIsReady(_ => true))
      )
      audioRef
      ->getCurrent
      ->Belt.Option.forEach(a =>
        AudioHtmlBindings.addEventListener(a, "loadstart", () => setIsReady(_ => false))
      )

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
      <div className="playerControls">
        <button onClick={prevAudio} disabled={!isReady}> {React.string("<<")} </button>
        <button onClick={stopAudio} disabled={!isReady}> {React.string("Stop")} </button>
        {switch isPlaying {
        | true =>
          <button onClick={pauseAudio} disabled={!isReady}> {React.string("Pause")} </button>
        | false => <button onClick={playAudio} disabled={!isReady}> {React.string("Play")} </button>
        }}
        <button onClick={nextAudio} disabled={!isReady}> {React.string(">>")} </button>
      </div>
      <MysticImage loading={waiting} playing={isPlaying} />
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
  let (selectedSongId: int, setSelectedSongId) = React.useState(_prev => 0)
  let (selectedSong, setSelectedSong) = React.useState(_ => None)
  let audioRef = React.useRef(Js.Nullable.null)

  React.useEffect0(() => {
    let playListSongs = PlayListSource.getSongs()
    setSongs(_prev => playListSongs)
    Some(() => setSongs(_prev => []))
  })

  React.useEffect1(() => {
    if Array.length(songs) > 0 {
      let newSong: Playlist.song = songs[selectedSongId]
      setSelectedSong(_ => Some(newSong))
    }
    None
  }, [selectedSongId])

  let pickSong = (song: Playlist.song, songId: int): unit => {
    setSelectedSong(_ => Some(song))
    setSelectedSongId(_ => songId)
  }

  let nextSong = (): unit => {
    if selectedSongId == Array.length(songs) - 1 {
      setSelectedSongId(_ => 0)
    } else {
      setSelectedSongId(id => id + 1)
    }
  }

  let prevSong = (): unit => {
    if selectedSongId == 0 {
      setSelectedSongId(_ => Array.length(songs) - 1)
    } else {
      setSelectedSongId(id => id - 1)
    }
  }

  let shuffler = (): unit => {
    let shuffledSongs: array<Playlist.song> = Belt.Array.shuffle(songs)
    setSongs(_ => shuffledSongs)
    switch selectedSong {
    | Some(songSelected) =>
      switch Belt.Array.getIndexBy(shuffledSongs, song => song.url == songSelected.url) {
      | Some(songId) => setSelectedSongId(_ => songId)
      | None => ()
      }
    | None => ()
    }
    ()
  }

  <div>
    <Playlist
      songs={songs} selectSong={pickSong} selectedSong={selectedSongId} shuffler={shuffler}
    />
    {switch selectedSong {
    | Some(songSelected) =>
      <div>
        <div> {React.string(songSelected.name)} </div>
        <AudioTrack audioRef={ReactDOM.Ref.domRef(audioRef)} trackUrl={songSelected.url} />
        <AudioControls audioRef song={songSelected} nextSong={nextSong} prevSong={prevSong} />
      </div>
    | None => <div />
    }}
  </div>
}
