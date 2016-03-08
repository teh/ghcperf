{ stdenv }:
stdenv.mkDerivation {
  name = "ghcperf-driver";
  src = ./.; # TODO filter just driver and perf dirs.
  phases = "unpackPhase installPhase";
  installPhase = ''
    mkdir $out;
    cp -r * $out/
  '';
}
