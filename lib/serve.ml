open Js_of_ocaml

let resolve_asset read path =
  let read_asset path =
    match read path with
    | Some content -> Some (path, content)
    | None -> None
  in
  let path = if path = "/" then "/index.html" else path in
  match read_asset path with
  | Some asset -> Some asset
  | None ->
    let with_index =
      if String.length path > 0 && path.[String.length path - 1] = '/'
      then path ^ "index.html"
      else path ^ "/index.html"
    in
    read_asset with_index
;;

let request_path (event : Js.Unsafe.any) =
  let req = Js.Unsafe.get event (Js.string "request") in
  let url =
    Js.Unsafe.new_obj Js.Unsafe.global##._URL [| Js.Unsafe.get req (Js.string "url") |]
  in
  Js.to_string (Js.Unsafe.get url (Js.string "pathname"))
;;

module Make (A : Sigs.ASSETS) : Sigs.HANDLER = struct
  let handle event =
    let path = request_path event in
    match resolve_asset A.read path with
    | Some (resolved, content) ->
      Response.make ~status:200 content [ "content-type", Magic_mime.lookup resolved ]
    | None -> Response.not_found ()
  ;;
end

let listen (module H : Sigs.HANDLER) =
  let callback =
    Js.wrap_callback (fun event ->
      let response = H.handle event in
      ignore (Js.Unsafe.meth_call event "respondWith" [| Js.Unsafe.inject response |]))
  in
  ignore
    (Js.Unsafe.meth_call
       Js.Unsafe.global
       "addEventListener"
       [| Js.Unsafe.inject (Js.string "fetch"); Js.Unsafe.inject callback |])
;;
