let generate_bundle_source dir oc =
  let crunch = Crunch.make () in
  let crunch = Crunch.walk_directory_tree crunch [] Crunch.scan_file dir in
  Crunch.output_generated_by oc "crouton";
  Crunch.output_implementation crunch oc;
  Crunch.output_plain_skeleton_ml crunch oc;
  output_string oc "\n";
  output_string oc "module Assets = struct\n";
  output_string oc "  let read = read\n";
  output_string oc "end\n";
  output_string oc "\n";
  output_string oc "module Handler = Crouton.Serve.Make (Assets)\n";
  output_string oc "let () = Crouton.Serve.listen (module Handler)\n"
;;

let compile_with_jsoo source_file output_file =
  let bytecode_file = Filename.temp_file "crouton" ".bc" in
  let compile_cmd =
    Printf.sprintf
      "ocamlfind ocamlc -package crouton -linkpkg %s -o %s"
      (Filename.quote source_file)
      (Filename.quote bytecode_file)
  in
  let jsoo_cmd =
    Printf.sprintf
      "js_of_ocaml %s -o %s"
      (Filename.quote bytecode_file)
      (Filename.quote output_file)
  in
  let run cmd =
    let code = Sys.command cmd in
    if code <> 0
    then (
      Printf.eprintf "command failed with exit code %d: %s\n" code cmd;
      exit 1)
  in
  run compile_cmd;
  run jsoo_cmd;
  Sys.remove bytecode_file
;;

let run dir output =
  let source_file = Filename.temp_file "crouton" ".ml" in
  let oc = open_out source_file in
  generate_bundle_source dir oc;
  close_out oc;
  compile_with_jsoo source_file output;
  Sys.remove source_file
;;

open Cmdliner

let dir_arg =
  let doc = "directory containing static files to bundle" in
  Arg.(required (pos 0 (some dir) None (info ~doc ~docv:"DIR" [])))
;;

let output_arg =
  let doc = "output javascript file" in
  Arg.(value (opt string "bundle.js" (info ~doc ~docv:"FILE" [ "o"; "output" ])))
;;

let cmd =
  let doc = "bundle static files into a js edge handler" in
  let info = Cmd.info "crouton" ~doc in
  let term = Term.(const run $ dir_arg $ output_arg) in
  Cmd.v info term
;;

let () = exit (Cmd.eval cmd)
