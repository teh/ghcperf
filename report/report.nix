# Call like nix-build driver.nix --arg latest_sha 12
{ pkgs ? (import <nixpkgs> {}), timestamp}:
with pkgs;
let
  secrets = import ../aws_secrets.nix;
in
stdenv.mkDerivation {
  name = "report-as-of-${timestamp}";
  srcs = ./.;
  phases = "unpackPhase buildPhase installPhase";
  buildInputs = with pythonPackages; [
    notebook
    pandas
    matplotlib
    ipython
    awscli
    s3cmd
    seaborn
  ];
  buildPhase = ''
    HOME=$PWD jupyter-nbconvert --debug --execute report.ipynb
  '';
  installPhase = ''
    mkdir $out
    cp report.html $out/
    s3cmd -P --access_key="${secrets.AWS_ACCESS_KEY_ID}" --secret_key="${secrets.AWS_SECRET_ACCESS_KEY}" put report.html "s3://ghcperf-reports/${timestamp}.html"
    s3cmd -P --force --access_key="${secrets.AWS_ACCESS_KEY_ID}" --secret_key="${secrets.AWS_SECRET_ACCESS_KEY}" put report.html "s3://ghcperf-reports/latest.html"
  '';
}
