@send external pause: Dom.element => unit = "pause"
@send external play: Dom.element => unit = "play"
@get external currentTime: Dom.element => int = "currentTime"
@get external duration: Dom.element => int = "duration"
@send external addEventListener: (Dom.element, string, unit => unit) => unit = "addEventListener"
@send
external removeEventListener: (Dom.element, string, unit => unit) => unit = "removeEventListener"

@react.component
let make = (~audioRef: React.ref<Js.Nullable.t<Dom.element>>) => {
  let (isPlaying, setIsPlaying) = React.useState(_ => false)
  let (pctPlayed, setPctPlayed) = React.useState(_ => "0")
  let audio = audioRef.current->Js.Nullable.toOption
  let pauseAudio = _ => {
    audio->Belt.Option.forEach(a => {
      a->pause
      setIsPlaying(_prev => false)
    })
  }
  let playAudio = _ => {
    audio->Belt.Option.forEach(a => {
      a->play
      setIsPlaying(_prev => true)
    })
  }

  // Maybe Events are not the way to go, should use a more React-ish implementation
  // FIXME: And as it's right now, removeEventListener won't work either
  React.useEffect0(() => {
    let handleTimeUpdate = a =>
      setPctPlayed(_ => (a->currentTime * 100 / a->duration)->Belt.Int.toString)
    audio->Belt.Option.forEach(a => addEventListener(a, "timeupdate", () => a->handleTimeUpdate))
    let cleanUp = () =>
      audio->Belt.Option.forEach(a => removeEventListener(a, "timeupdate", () => a->handleTimeUpdate))
    Some(cleanUp)
  })
  <div>
    <div>
      <progress value={pctPlayed} max="100" />
    </div>
    {isPlaying
      ? <button onClick=pauseAudio> {React.string("Pause")} </button>
      : <button onClick=playAudio> {React.string("Play")} </button>}
  </div>
}
