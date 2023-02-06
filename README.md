# What/why

I couldn't figure out how to run silverbullet on nix (I tried with [this project's help](https://github.com/SnO2WMaN/deno2nix/) but silverbullet doesn't ship a lockfile, and when I forked it to add a lockfile, it didn't seem to be stable).

I also didn't want to just drop the compiled silverbullet.js file into my main nix repo as it's currently just over 16MB. So I created this repo that keeps a copy of the silverbullet compiled js file, which I can add to my main nix repo.

# Running the flake

Running silverbullet requires an existing directory to initialise in.

```bash
mkdir space
nix run .# -- ./space
```

# Updating the silverbullet.js file

```bash
nix run .#updateBin
git commit -a
```

# Adding the overlay to a system flake

```nix
{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11";
  inputs.silverbullet.url = "github:jay-aye-see-kay/silverbullet";

  outputs = { nixpkgs, silverbullet, ... }:
  let
    pkgs = import nixpkgs {
      system = ${system};
      overlays = [
        silverbullet.overlays.${system}.default
      ];
    };
  in
  { ... };
}
```

# Running silverbullet as a systemd service

TODO
