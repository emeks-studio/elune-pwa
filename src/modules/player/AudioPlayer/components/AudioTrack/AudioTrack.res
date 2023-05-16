@react.component
let make = (~audioRef: ReactDOM.domRef, ~trackUrl: string) => {
  <div>
    <audio src=trackUrl ref=audioRef />
  </div>
}
