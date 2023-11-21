#!/usr/bin/env bash
dune exec backend -- -s _build/default/frontend/ -dbu admin -dbp password -dburi http://localhost:5984/
