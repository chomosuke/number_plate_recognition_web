(lang dune 3.11)

(name number_plate_recognition)

(generate_opam_files true)

(source
 (github chomosuke/number_plate_recognition_web))

(authors "Richard Li")

(maintainers "Richard Li")

(license LICENSE)

(documentation https://url/to/documentation)

(package
 (name number_plate_recognition)
 (synopsis "A short synopsis")
 (description "A longer description")
 (depends
   ocaml
   dune
   (ocamlformat (= 0.26.1))
   core
   bonsai
   async
   cohttp-async
   yojson
   ppx_jane
   js_of_ocaml-compiler)
 (tags
  (topics "to describe" your project)))

; See the complete stanza docs at https://dune.readthedocs.io/en/stable/dune-files.html#dune-project
