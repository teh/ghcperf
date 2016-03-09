{ mkDerivation, base, containers, ghc-prim, stdenv
, template-haskell
}:
mkDerivation {
  pname = "generic-deriving";
  version = "1.10.0";
  sha256 = "1r3s1m1aip9ikffycx8la5yfb8b4kxkmxsdv7ryagnzg2crc4y43";
  libraryHaskellDepends = [
    base containers ghc-prim template-haskell
  ];
  homepage = "https://github.com/dreixel/generic-deriving";
  description = "Generic programming library for generalised deriving";
  license = stdenv.lib.licenses.bsd3;

  # dunno where this comes from:
  # Mar 09 11:13:40 ghcperf ghcperf-start[16800]: Linking Setup ...
  # Mar 09 11:13:41 ghcperf ghcperf-start[16800]: Preprocessing library generic-deriving-1.10.0...
  # Mar 09 11:13:42 ghcperf ghcperf-start[16800]: src/Generics/Deriving/TH.hs:24:1: error:
  # Mar 09 11:13:42 ghcperf ghcperf-start[16800]: parse error on input ‘-- $('deriveAll0'     ''Example) -- Derives Generic instance’

  # https://github.com/dreixel/generic-deriving/issues/36
  patches = [ ./fix-cpp-error.patch ];
}
