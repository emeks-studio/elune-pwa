@react.component
let make = () => {
  let audioRef = React.useRef(Js.Nullable.null)
  let trackUrl = "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3"
  <div>
    <AudioTrack audioRef={ReactDOM.Ref.domRef(audioRef)} trackUrl />
    <AudioControls audioRef />
  </div>
}
