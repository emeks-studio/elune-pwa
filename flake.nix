{
  description = "Flake for elune";

  nixConfig = {
    # TODO: Add cache!
    bash-prompt = "\\[\\e[0;37m\\](\\[\\e[0m\\]nix) \\[\\e[0;1;32m\\]elune\\[\\e[0m\\]\\w \\[\\e[0;1m\\]λ \\[\\e[0m\\]";
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
    rescript-compiler = {
      url = "github:rescript-lang/rescript-compiler?ref=10.1.3";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, flake-utils, rescript-compiler }:
    # TODO: Add linter hooks?
    flake-utils.lib.eachSystem [ "x86_64-linux" ] (system:
      let
        pkgs = import nixpkgs { inherit system; };
        stdenv = pkgs.stdenv;
        nodejs = pkgs.nodejs-18_x;
        python3 = pkgs.python39;
        ocaml-ng = pkgs.ocaml-ng;
        rescript = pkgs.callPackage ./rescript.nix { 
          inherit stdenv nodejs python3 ocaml-ng  rescript-compiler; 
        };
        NPM_CONFIG_PREFIX = toString ./npm_config_prefix;
      in
        {
          devShell = pkgs.mkShell {
            buildInputs = [
              nodejs
              rescript
            ];
            shellHook = ''
              modules="$PWD/node_modules"
              mkdir -p "$modules"
              rm -rf "$modules/rescript"
              ln -s ${rescript} "$modules/rescript"
              npm install
              export PATH="${rescript}:$modules/.bin:$PATH"
              export PATH="${NPM_CONFIG_PREFIX}/bin:$PATH"
            '';
          }; 
        }
    );
}
