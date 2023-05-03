{
  description = "Flake for elune";

  nixConfig = {
    # TODO: Add cache!
    bash-prompt = "\\[\\e[0;37m\\](\\[\\e[0m\\]nix) \\[\\e[0;1;32m\\]elune\\[\\e[0m\\]\\w \\[\\e[0;1m\\]λ \\[\\e[0m\\]";
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    # TODO: Add linter hooks?
    flake-utils.lib.eachSystem [ "x86_64-linux" ] (system:
      let
        pkgs = import nixpkgs { inherit system; };
        NPM_CONFIG_PREFIX = toString ./npm_config_prefix;
      in
        {
          devShell = pkgs.mkShell {
            buildInputs = [
              pkgs.nodejs-18_x
              pkgs.python3 # Required by Rescript given is using "Ninja" build system
            ];
            shellHook = ''
              export PATH="${NPM_CONFIG_PREFIX}/bin:$PATH"
            '';
          }; 
        }
    );
}
