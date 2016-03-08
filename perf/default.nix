with (import <nixpkgs> {}).pkgs;
let
ghc-master = callPackage ./ghc-master.nix rec {
  bootPkgs = haskell.packages.ghc7103;
  inherit (bootPkgs) alex happy;
};
packages = callPackage <nixpkgs/pkgs/development/haskell-modules> {
    ghc = ghc-master;
    compilerConfig = callPackage <nixpkgs/pkgs/development/haskell-modules/configuration-ghc-head.nix> {};
};
hp = packages.override {
  overrides = self: super: {
    mkDerivation = haskellPackages.callPackage ./generic-builder.nix { ghc = ghc-master; };
  };
};
in {
  ghc = ghc-master;
  measure = {
    aeson = hp.aeson.overrideDerivation (old: { version="perf-1"; });
  };
}
