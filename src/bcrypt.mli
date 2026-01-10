type error =
  [ `Hash_failure
  | `Invalid_cost of string
  | `Invalid_hash of string
  | `Invalid_prefix of string
  | `Invalid_salt_length of int
  | `Salt_generation_failure
  | `Truncated of int
  ]

val pp_error : Format.formatter -> error -> unit
val hash_with_salt : salt:string -> string -> (Hash.t, error) result
val hash : ?cost:int -> string -> (Hash.t, error) result
val verify : hash:Hash.t -> string -> (bool, error) result
