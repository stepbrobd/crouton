module type ASSETS = sig
  val read : string -> string option
end

module type HANDLER = sig
  val handle : Js_of_ocaml.Js.Unsafe.any -> Js_of_ocaml.Js.Unsafe.any
end
