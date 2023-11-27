#!/usr/bin/env bash
COHTTP_DEBUG=1 _build/default/backend/backend.exe -secret dummy -path _build/default/frontend/ -dbu admin -dbp password -dburi http://localhost:5984/
