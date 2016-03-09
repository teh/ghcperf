with (import <nixpkgs> {}).pkgs;
let
ghc-master = callPackage ./ghc-master.nix rec {
  bootPkgs = haskell.packages.ghc7103;
  inherit (bootPkgs) alex happy;
};
packages = callPackage <nixpkgs/pkgs/development/haskell-modules> {
    ghc = ghc-master;
    compilerConfig = callPackage ./configuration-ghc-head.nix {};
};
hp = packages.override {
  overrides = self: super: {
    mkDerivation = packages.callPackage ./generic-builder.nix { ghc = ghc-master; perf = linuxPackages.perf; };
  };
};
# Build 3 of each for now
buildN = name: (builtins.listToAttrs (map (
      x: { name = "${name}-run-${toString x}";
           value = (builtins.getAttr name hp ).overrideDerivation (old: { version = "${toString x}";});
         }) [1 2 3]));
in {
  ghc = ghc-master;
  # We have to be a bit selective with the libraries we are timing
  # because many dependencies don't build on 8.1 yet
  # (e.g. generic-deriving needed hacks, pipes has old transformer).
  #
  # Also note that this doesn't build the dependencies 3 times so wee
  # need to enumerate those explicitly (for now).
  measure = buildN "text" // buildN "aeson";

  # want to try warp but that implicitly depends on doctests which
  # breaks: https://github.com/sol/doctest/issues/125
}
