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
        path = with pkgs;[ nixUnstable coreutils gnutar gzip ];

        # http://lists.science.uu.nl/pipermail/nix-dev/2015-October/018343.html
        environment = config.environment.sessionVariables;
        script = ''
          export
          export NIX_PATH=nixpkgs=https://github.com/NixOS/nixpkgs-channels/archive/nixos-unstable.tar.gz
          exec nix-build ${cfg.package}/driver.nix --arg timestamp "\"$(date -Iseconds)\""
        '';
    };
    systemd.timers."ghcperf" = {
      wantedBy = [ "timers.target" ];
      timerConfig.OnBootSec = "15min";
      timerConfig.OnUnitInactiveSec = "1h"; # wait 1h between runs.
    };
  };
}
