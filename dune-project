(lang dune 3.21)

(generate_opam_files true)
(executables_implicit_empty_intf true)

(name crouton)
(version 2026.406.0)
(license MIT)
(authors "Yifei Sun <ysun@hey.com>")
(maintainers "Yifei Sun <ysun@hey.com>")

(package
  (name crouton)
  (depends
   cmdliner
   crunch
   js_of_ocaml
   js_of_ocaml-compiler
   js_of_ocaml-ppx
   magic-mime))
