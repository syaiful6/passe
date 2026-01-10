type t = string

external of_string : string -> t = "%identity"
external to_string : t -> string = "%identity"

let pp fmt t = Format.fprintf fmt "%s" (to_string t)
