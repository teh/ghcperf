# GHC perf

This project aims to track GHC compiler performance for building
common libraries over time. It uses the Nix package manager to build
libraries because Nix makes it trivial to change package builders to
e.g. include performance measurements.


# Technical details

This project contains a driver that checks for the most recent GHC
HEAD every hour. If GHC HEAD changed then Nix will see a new compiler
hash and re-build all dependent packages. If the hash is the same


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
