open Js_of_ocaml

let string_to_uint8array s =
  let len = String.length s in
  let arr = Js.Unsafe.new_obj Js.Unsafe.global##._Uint8Array [| Js.Unsafe.inject len |] in
  for i = 0 to len - 1 do
    Js.Unsafe.set arr i (Char.code s.[i])
  done;
  arr
;;

let make ~status content headers : Js.Unsafe.any =
  let h = Js.Unsafe.new_obj Js.Unsafe.global##._Headers [||] in
  List.iter
    (fun (k, v) ->
       ignore
         (Js.Unsafe.meth_call
            h
            "set"
            [| Js.Unsafe.inject (Js.string k); Js.Unsafe.inject (Js.string v) |]))
    headers;
  let opts =
    Js.Unsafe.obj [| "status", Js.Unsafe.inject status; "headers", Js.Unsafe.inject h |]
  in
  Js.Unsafe.new_obj
    Js.Unsafe.global##._Response
    [| Js.Unsafe.inject (string_to_uint8array content); Js.Unsafe.inject opts |]
;;

let not_found () = make ~status:404 "not found" [ "content-type", "text/plain" ]
