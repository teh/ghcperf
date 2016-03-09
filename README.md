# GHC perf

This project aims to track GHC compiler performance for building
common libraries over time. It uses the Nix package manager to build
libraries because Nix makes it trivial to change package builders to
e.g. include performance measurements.


# Technical details

This project contains a driver that checks for the most recent GHC
HEAD every hour. If GHC HEAD changed then Nix will see a new compiler
hash and re-build all dependent packages. If the hash is the same


# Problems

**PMU** - ec2 doesn't give access to PMUs. cpu-clock is pretty useless


# Design decisions

**Don't build every commit.** If several commits land in master
between builds we would still be able to pinpoint performance
regressions to a fairly small time window.

**Use perf.** Perf counts CPU cycles used by the program. CPU cycle
counts change between runs because of on non-deterministic behaviour
in the compiler, various OS resources not being ready (EINTR etc) and
signal handlers etc. But they are reasonably stable.

**Do three runs and take fastest.** Not sure why yet but runs get
faster over time. The obvious candidate reason is buffers. In order to
get around this we run three times and take the best time.


# Data

The data is dumped for ghc commits here:
http://ghcperf-results.s3.amazonaws.com/

Note that we're building every hour ATM, not on every commit so there
may be holes in the data.


# Deploying your own server

You will need get the following environment variables:

```
export AWS_ACCESS_KEY_ID="..."
export AWS_SECRET_ACCESS_KEY="..."
export NIXOPS_STATE=./conf/state.nixops
export NIX_PATH=nixpkgs=https://github.com/NixOS/nixpkgs-channels/archive/nixos-16.03-beta.tar.gz:.
```

A `secrets.nix` and modify the elastic IP + domain for nginx (or
disable that). Then run

```
nixops create <server.nix>
nixops deploy
```

If you've been outbid on the spot-price market try:

```
nixops deploy --check --allow-recreate
```
