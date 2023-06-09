# elune-pwa
PWA for elune player

## Development

### nix (development env)

Install [nix](https://nixos.org/download.html#download-nix) and turn on [flakes](https://nixos.wiki/wiki/Flakes).

```
nix develop --impure
```
^ Enters the development shell using nix. Obs: Impure flag is because for NixOS environments,
we need to enable nix-ld `programs.nix-ld.enable = true;` in configuration.nix in order to fix
rescript language server calls to dynamic linked libraries.



### `$ npm start`
Runs the app in the development mode.\
Open [http://localhost:3000](http://localhost:3000) to view it in your browser.

The page will reload when you make changes.\
You may also see any lint errors in the console.

### `$ npm run re:dev`
Runs rescript compiler against src/ and keep watching .res file changes

## Build
### `$ npm run build`
Builds the app for production to the `build\` folder.\
It correctly bundles React in production mode and optimizes the build for the best performance.

The build is minified and the filenames include the hashes.\
See this section about [deployment](https://facebook.github.io/create-react-app/docs/deployment) for more information.
