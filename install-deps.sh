#!/usr/bin/env bash
dune build
opam install . --deps-only --with-test
