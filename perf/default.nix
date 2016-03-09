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
buildN = name: (builtins.listToAttrs (map (
      x: { name = "${name}-run-${toString x}";
           value = (builtins.getAttr name hp ).overrideDerivation (old: { version = "${toString x}";});
         }) [1 2 3]));
in {
  ghc = ghc-master;
  measure = buildN "aeson";
}
