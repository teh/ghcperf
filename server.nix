# You'll also need to export the secret key like this:
# export AWS_ACCESS_KEY_ID=...
# export AWS_SECRET_ACCESS_KEY=...
let
    region = "us-west-2";
    common-config = {
        nix.gc.automatic = true;
        nix.gc.dates = "08:00";
        nix.gc.options = "--delete-older-than 7d";

        # Enable a basic firewall
        networking.firewall.enable = true;
        networking.firewall.allowedTCPPorts = [ 22 80 443 ];
        networking.firewall.allowPing = true;

        # Limit logs
        services.journald.extraConfig = "SystemMaxUse=1G";
    };

in
rec {
    network.enableRollback = true;
    network.description = "ghcperf";

    resources.ec2KeyPairs.waw-pair =
        { inherit region; };

    resources.ec2SecurityGroups.http-ssh = {
        inherit region;
        rules = [
            { fromPort = 22; toPort = 22; sourceIp = "0.0.0.0/0"; }
            { fromPort = 80; toPort = 80; sourceIp = "0.0.0.0/0"; }
            { fromPort = 443; toPort = 443; sourceIp = "0.0.0.0/0"; }
        ];
    };

    ghcperf = { resources, pkgs, lib, ... }:
    let
      ghcperf-driver = pkgs.callPackage ./ghcperf-driver.nix {};
    in
    (common-config // {
        deployment.targetEnv = "ec2";
        deployment.ec2.region = region;
        deployment.ec2.instanceType = "c3.large";
        deployment.ec2.spotInstancePrice = 4;
        deployment.ec2.ebsInitialRootDiskSize = 20;
        deployment.ec2.keyPair = resources.ec2KeyPairs.waw-pair;
        deployment.ec2.securityGroups = [ resources.ec2SecurityGroups.http-ssh ];

        environment.systemPackages = with pkgs;[ git vim perf-tools ];

        require = [
         ./ghcperf-module.nix
        ];
        services.ghcperf.package = ghcperf-driver;
        boot.kernel.sysctl."vm.swappiness" = 0;
        boot.kernel.sysctl."kernel.perf_event_paranoid" = -1;
    });
}
