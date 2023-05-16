%%raw("import './App.css'")

@react.component
let make = () => {
  let dummyList = Belt.List.add(list{1,2,3}, 4)
  Js.log2(dummyList, dummyList->Belt.List.toArray)
  <div className="App">
      <header className="App-header">
      <p>{React.string("Elune PWA")}</p>
      <AudioPlayer />
    </header>
  </div>
};
