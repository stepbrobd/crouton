{ lib
, buildDunePackage
, cmdliner
, crunch
, js_of_ocaml
, js_of_ocaml-compiler
, js_of_ocaml-ppx
, magic-mime
}:

buildDunePackage (finalAttrs: {
  pname = "crouton";
  version = with lib; pipe ./dune-project [
    readFile
    (match ".*\\(version ([^\n]+)\\).*")
    head
  ];

  src = with lib.fileset; toSource {
    root = ./.;
    fileset = unions [
      ./bin
      ./lib
      ./dune-project
    ];
  };

  env.DUNE_CACHE = "disabled";

  propagatedBuildInputs = [
    cmdliner
    crunch
    js_of_ocaml
    js_of_ocaml-compiler
    js_of_ocaml-ppx
    magic-mime
  ];
})
