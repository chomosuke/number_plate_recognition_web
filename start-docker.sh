#!/usr/bin/env bash
docker run -p 8000:8000 -e SECRET=dummySecret -e DB_USERNAME=admin -e DB_PASSWORD=password -e DB_URI=http://54.252.244.93:5984/ -e COHTTP_DEBUG=1 "$@"
