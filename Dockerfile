FROM ocaml/opam:debian-12-ocaml-5.0
RUN sudo apt-get update && sudo apt-get install -y pkg-config libffi-dev libgmp-dev libssl-dev zlib1g-dev
WORKDIR /app
COPY ./number_plate_recognition.opam .
RUN opam install . --deps-only
COPY . .
RUN eval $(opam config env); dune build
CMD ./_build/default/backend/backend.exe -secret $SECRET -path ./_build/default/frontend/ -dbu $DB_USERNAME -dbp $DB_PASSWORD -dburi $DB_URI
