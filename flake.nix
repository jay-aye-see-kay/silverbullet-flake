{
  description = "A flake to run silverbullet";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { nixpkgs, flake-utils, ... }@inputs:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        silverbullet =
          pkgs.writeShellScriptBin "silverbullet"
            "${pkgs.deno}/bin/deno run -A --unstable ${./silverbullet.js} --hostname 0.0.0.0 $@";
        updateBin =
          pkgs.writeShellScriptBin "updateBin"
            "${pkgs.curl}/bin/curl https://get.silverbullet.md > silverbullet.js";
      in
      rec {
        apps.updateBin = { type = "app"; program = "${updateBin}/bin/updateBin"; };

        apps.default = { type = "app"; program = "${silverbullet}/bin/silverbullet"; };
        overlays.default = final: prev: { inherit silverbullet; };
      }
    );
}
