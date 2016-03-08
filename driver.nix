# Call like nix-build driver.nix --arg timestamp 12
{ pkgs ? (import <nixpkgs> {}), timestamp }:
pkgs.stdenv.mkDerivation {
  name = "ghcperf-data";

  buildInputs = with pkgs; [ nixUnstable python35 nix-prefetch-git ];

  src = ./perf;
  phases = "unpackPhase buildPhase installPhase";
  buildPhase = ''
    # TODO move to 16.03 as soon as it's out
    export SSL_CERT_FILE=/etc/ssl/certs/ca-bundle.crt # TODO: not sure why this is needed
    export NIX_PATH=nixpkgs=https://github.com/NixOS/nixpkgs-channels/archive/nixos-unstable.tar.gz
    export HOME=/tmp # needed for fetching the unstable channel, by
                     # using /tmp we get some caching.
    python3.5 driver.py
  '';
  installPhase = ''
    mkdir $out
    cp *.csv $out
    echo ${timestamp} > $out/build-timestamp
  '';
}
