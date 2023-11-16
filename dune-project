(lang dune 3.11)

(name number_plate_recognition)

(generate_opam_files true)

(source
 (github username/reponame))

(authors "Author Name")

(maintainers "Maintainer Name")

(license LICENSE)

(documentation https://url/to/documentation)

(package
 (name number_plate_recognition)
 (allow_empty)
 (synopsis "A short synopsis")
 (description "A longer description")
 (depends
   ocaml
   dune
   (ocamlformat (= 0.26.1))
   core
   ppx_jane
   js_of_ocaml-ppx
   js_of_ocaml-compiler)
 (tags
  (topics "to describe" your project)))

; See the complete stanza docs at https://dune.readthedocs.io/en/stable/dune-files.html#dune-project
