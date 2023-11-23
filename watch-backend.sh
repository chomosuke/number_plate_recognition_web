#!/usr/bin/env bash
dune exec backend -w -- -secret dummy -path _build/default/frontend/ -dbu admin -dbp password -dburi http://localhost:5984/
