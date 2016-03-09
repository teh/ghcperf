# Call like nix-build driver.nix --arg latest_sha 12
{ pkgs ? (import <nixpkgs> {}), latest_sha }:
let
  # Need at least 1.6 because before that s3cmd always needs ~/.s3cfg
  s3cmd-1-6 = pkgs.callPackage ./perf/nix-8.1/s3cmd-1.6.nix {};
  # Secrets is just a bit of data not checked into git which looks like this:
  # {
  #   AWS_ACCESS_KEY_ID = "A....";
  #   AWS_SECRET_ACCESS_KEY = "4...";
  # }
  secrets = import ./aws_secrets.nix;
in
pkgs.stdenv.mkDerivation {
  name = "ghcperf-data";
  buildInputs = with pkgs; [ nixUnstable python35 nix-prefetch-git s3cmd-1-6 ];

  src = ./perf;
  phases = "unpackPhase buildPhase installPhase";
  buildPhase = ''
    # Can't use nixos-16.03 because that has a broken nix-prefetch-url in it.
    export SSL_CERT_FILE=/etc/ssl/certs/ca-bundle.crt # TODO: not sure why this is needed
    export NIX_PATH=nixpkgs=https://github.com/NixOS/nixpkgs-channels/archive/nixos-unstable.tar.gz
    export AWS_ACCESS_KEY_ID="${secrets.AWS_ACCESS_KEY_ID}"
    export AWS_SECRET_ACCESS_KEY="${secrets.AWS_SECRET_ACCESS_KEY}"

    # needed for fetching the unstable channel, by using /tmp we get
    # some caching.
    export HOME=$PWD
    python3.5 driver.py
  '';
  installPhase = ''
    mkdir $out
    cp *.csv $out
    echo ${latest_sha} > $out/master_sha

    ${s3cmd-1-6}/bin/s3cmd --version
    # AWS_* needs to be set in the environment (see ghcperf-module)
    ${s3cmd-1-6}/bin/s3cmd --access_key="$AWS_ACCESS_KEY_ID" --secret_key="$AWS_SECRET_ACCESS_KEY" sync $out/* s3://ghcperf-results/${latest_sha}/
  '';
}
