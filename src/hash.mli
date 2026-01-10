type t

val of_string : string -> t
val pp : Format.formatter -> t -> unit
val to_string : t -> string
