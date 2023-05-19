
module AudioHtmlBindings = {
  @send external pause: Dom.element => unit = "pause"
  @send external play: Dom.element => unit = "play"
  @get external currentTime: Dom.element => int = "currentTime"
  @get external duration: Dom.element => int = "duration"
  @get external waiting: Dom.element => bool = "waiting"
  @send external addEventListener: (Dom.element, string, unit => unit) => unit = "addEventListener"
  @send external removeEventListener: (Dom.element, string, unit => unit) => unit = "removeEventListener"
}

let getCurrent = (audioRef: React.ref<Js.Nullable.t<Dom.element>>) : option<Dom.element> => {
  audioRef.current->Js.Nullable.toOption
}

module AudioControls = {
  @react.component
  let make = (~audioRef: React.ref<Js.Nullable.t<Dom.element>>) => {
    let (isPlaying, setIsPlaying) = React.useState(_ => false)
    let (pctPlayed, setPctPlayed) = React.useState(_ => "0")
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

    React.useEffect0(() => {
      let handleTimeUpdate = (a: Dom.element) => {
        let updateTime = a->AudioHtmlBindings.currentTime * 100 / a->AudioHtmlBindings.duration
        setPctPlayed(_ => updateTime->Belt.Int.toString)
      }

      let cb = () => 
        audioRef->getCurrent->Belt.Option.forEach(a => handleTimeUpdate(a))
      
      let cleanUp = () => 
        audioRef->getCurrent->Belt.Option.forEach(a => AudioHtmlBindings.removeEventListener(a, "timeupdate", cb))
      
      audioRef->getCurrent->Belt.Option.forEach(a => AudioHtmlBindings.addEventListener(a, "timeupdate", cb))
      Some(cleanUp)
    })

    <div>
      <div>
        <progress value={pctPlayed} max="100" />
      </div>
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
  }
}

module AudioTrack = {
  @react.component
  let make = (~audioRef: ReactDOM.domRef, ~trackUrl: string) => {
    <audio src=trackUrl ref=audioRef />
  }
}

@react.component
let make = () => {
  let audioRef = React.useRef(Js.Nullable.null) 
  let trackUrl = "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3"
  
  <div>
    <AudioTrack audioRef={ReactDOM.Ref.domRef(audioRef)} trackUrl />
    <AudioControls audioRef />
  </div>
}


