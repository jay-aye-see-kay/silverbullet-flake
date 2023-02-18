# Archived because no longer needed

I've since realised that silverbullet publishes the compiled `js` file as a github release. This means I have a permanent url to fetch known versions from and that's much tidier that using this flake. I've left the repo up for myself as reference.

Here is what I've used in place of this flake:

```nix
{
  systemd.services.silverbullet =
    let
      version = "0.2.11";
      silverbullet-js-file = pkgs.fetchurl {
        url = "https://github.com/silverbulletmd/silverbullet/releases/download/${version}/silverbullet.js";
        sha256 = "sha256-h0lASLNxJ5DZvaJbHpMI2PtRWCty1vPro1n8R5vHQME=";
      };
      silverbullet = pkgs.writeShellScriptBin "silverbullet"
        "${pkgs.deno}/bin/deno run -A --unstable ${silverbullet-js-file} $@";
    in
    {
      enable = true;
      description = "silverbullet.md serving my notes on port 2001";
      unitConfig = {
        Type = "simple";
      };
      serviceConfig = {
        ExecStart = "${silverbullet}/bin/silverbullet --port 2001 /home/jack/notes";
        User = "jack";
        Group = "users";
      };
      wantedBy = [ "multi-user.target" ];
    };
}
```

---

Original readme below

---

# What/why

I couldn't figure out how to run silverbullet on nix (I tried with [this project's help](https://github.com/SnO2WMaN/deno2nix/) but silverbullet doesn't ship a lockfile, and when I forked it to add a lockfile, it didn't seem to be stable).

I also didn't want to just drop the compiled silverbullet.js file into my main nix repo as it's currently just over 16MB. So I created this repo that keeps a copy of the silverbullet compiled js file, which I can add to my main nix repo.

# Running the flake

Running silverbullet requires an existing directory to initialise in.

```bash
mkdir space

# print help
nix run .# -- --help

# run server (allowing remote connections)
nix run .# -- --hostname 0.0.0.0 ./space
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

```nix
{
  systemd.services.silverbullet = {
    enable = true;
    unitConfig = {
      Type = "simple";
    };
    serviceConfig = {
      ExecStart = "${pkgs.silverbullet}/bin/silverbullet --port 2001 /srv/notes";
    };
    wantedBy = [ "multi-user.target" ];
  };
}
```
