type hash = Hash.t

val hash_to_string : hash -> string
val hash_of_string : string -> hash

module Bcrypt : sig
  module Variant : sig
    type t =
      | A
      | Y
      | B

    val pp : Format.formatter -> t -> unit
    val of_raw_string : string -> t option
    val to_string : t -> string
  end

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
  val hash_with_salt : salt:string -> string -> (hash, error) result
  val hash : ?cost:int -> string -> (hash, error) result
  val verify : hash:hash -> string -> (bool, error) result
end
