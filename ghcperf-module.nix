{ config, pkgs, lib, ... }:
with lib;
let
  cfg = config.services.ghcperf;
in
{
  options = {
    services.ghcperf = rec {
      package = mkOption {
        type = types.package;
        default = null;
        description = "package";
      };
    };
  };
  config = {
    systemd.services."ghcperf" = {
        requires = [ "network.target" ];
        after = [ "network.target" ];
        path = with pkgs;[ nixUnstable coreutils gnutar gzip curl jq ];

        # http://lists.science.uu.nl/pipermail/nix-dev/2015-October/018343.html
        environment = config.environment.sessionVariables;
        script = ''
          export SSL_CERT_FILE=/etc/ssl/certs/ca-bundle.crt # TODO: not sure why this is needed
          export NIX_PATH=nixpkgs=https://github.com/NixOS/nixpkgs-channels/archive/nixos-unstable.tar.gz
          export LATEST_SHA="$(curl https://api.github.com/repos/ghc/ghc/git/refs/heads/master | jq -r .object.sha)"
          echo "LATEST_SHA=$LATEST_SHA"
          nix-build ${cfg.package}/driver.nix --arg latest_sha "\"$LATEST_SHA\""
        '';
    };
    systemd.timers."ghcperf" = {
      wantedBy = [ "timers.target" ];
      timerConfig.OnBootSec = "15min";
      timerConfig.OnUnitInactiveSec = "1h"; # wait 1h between runs.
    };
  };
}
