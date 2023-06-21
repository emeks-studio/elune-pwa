%%raw("import './AudioPlayer.css'")

module AudioHtmlBindings = {
  @send external pause: Dom.element => unit = "pause"
  @send external play: Dom.element => unit = "play"
  @set external setCurrentTime: (Dom.element, int) => unit = "currentTime"
  @get external currentTime: Dom.element => int = "currentTime"
  @get external duration: Dom.element => int = "duration"
  @get external waiting: Dom.element => bool = "waiting"
  @send external addEventListener: (Dom.element, string, unit => unit) => unit = "addEventListener"
  @send external removeEventListener: (Dom.element, string, unit => unit) => unit = "removeEventListener"
}

let getCurrent = (audioRef: React.ref<Js.Nullable.t<Dom.element>>) : option<Dom.element> => {
  audioRef.current->Js.Nullable.toOption
}

let formatTime = (secs: int): string => {
  let minutes : int = secs / 60;
  let seconds : int = mod(secs, 60) / 1

  let formattedMinutes = Belt.Int.toString(minutes);
  let formattedSeconds = Belt.Int.toString(seconds);

  if (formattedSeconds->String.length < 2) {
    formattedMinutes ++ ":0" ++ formattedSeconds;
  }else{
    formattedMinutes ++ ":" ++ formattedSeconds;
  }
};

module AudioControls = {
  @react.component
  let make = (~audioRef: React.ref<Js.Nullable.t<Dom.element>>, ~song: PlayList.song) => {
    let (isPlaying, setIsPlaying) = React.useState(_ => false)
    let (pctPlayed, setPctPlayed) = React.useState(_ => "0")
    let (duration, setDuration) = React.useState(_ => "00:00")
    let (timer, setTimer) = React.useState(_ => "00:00")

    let pauseAudio = _ => {
      audioRef->getCurrent->Belt.Option.forEach(a => {
        a->AudioHtmlBindings.pause
        setIsPlaying(_prev => false)
      })
    }

    let playAudio = _ => {
      // Js.Console.log2("playAudio clicked", audioRef.current->Js.Nullable.toOption)
      audioRef->getCurrent->Belt.Option.forEach(a => {
        a->AudioHtmlBindings.play
        setIsPlaying(_prev => true)
      })
    }

    let stopAudio = _ => {
      audioRef->getCurrent->Belt.Option.forEach(a => {
        a->AudioHtmlBindings.pause
        AudioHtmlBindings.setCurrentTime(a, 0)
      })
      setIsPlaying(_prev => false)
      setPctPlayed(_prev => "0")
      setTimer(_prev => "00:00")
    }

    React.useEffect1(() => {
      let handleTimeUpdate = (a: Dom.element) => {
        let updateTime = a->AudioHtmlBindings.currentTime * 100 / a->AudioHtmlBindings.duration
        setPctPlayed(_ => updateTime->Belt.Int.toString)
        setTimer(_ => a->AudioHtmlBindings.currentTime -> formatTime)
      }

      let getDuration = () => {
        audioRef->getCurrent->Belt.Option.forEach(a => setDuration(_ => a->AudioHtmlBindings.duration->formatTime))
      }
      
      let cb = () => 
        audioRef->getCurrent->Belt.Option.forEach(a => handleTimeUpdate(a))
      
      let cleanUp = () => 
        audioRef->getCurrent->Belt.Option.forEach(a => AudioHtmlBindings.removeEventListener(a, "timeupdate", cb))
        audioRef->getCurrent->Belt.Option.forEach(a => AudioHtmlBindings.removeEventListener(a, "loadedmetadata", getDuration))
      
      audioRef->getCurrent->Belt.Option.forEach(a => AudioHtmlBindings.addEventListener(a, "timeupdate", cb))
      audioRef->getCurrent->Belt.Option.forEach(a => AudioHtmlBindings.addEventListener(a, "loadedmetadata", getDuration))
      setIsPlaying(_ => false)
      Some(cleanUp)
    }, [song])

    <div>
      <div>
        <div className="trackInfo">{React.string(`Now Playing: ${song.name} by: ${song.artist}`)}</div>
        <div className="progressReproduction">
          <div className="progressTimer">{React.string(timer)}</div>
          <progress value={pctPlayed} max="100" />
          <div className="progressTimer">{React.string(duration)}</div>
        </div>
      </div>
      <div className="Playercontrols">
        <button onClick=stopAudio> {React.string("Stop")} </button>
        {isPlaying
          ? <button onClick=pauseAudio> {React.string("Pause")} </button>
          : <>
                <button onClick=playAudio> {React.string("Play")} </button>
              <div>
                {switch (audioRef->getCurrent) {
                | None => React.null
                | Some(a) => 
                  // Not sure if is worthy!
                  if (a->AudioHtmlBindings.waiting) {
                    <div> {React.string("Loading...")} </div>
                  } else {
                  React.null
                  }
                }}
              </div>
            </>
        }
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
let make = (~songToPlay: option<PlayList.song>) => {
  let audioRef = React.useRef(Js.Nullable.null)

  switch(songToPlay){
    |Some(songToPlay) =>   <div>
                            <AudioTrack audioRef={ReactDOM.Ref.domRef(audioRef)} trackUrl={songToPlay.url} />
                            <AudioControls audioRef song={songToPlay} />
                          </div>
    |None => <div></div>
  }
  

}


