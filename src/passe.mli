type hash = Hash.t

val hash_to_string : hash -> string
val hash_of_string : string -> hash

module Bcrypt : sig
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

module Argon2 : sig
  type error =
    [ `Invalid_time_cost of string
    | `Invalid_memory_cost of string
    | `Invalid_parallelism of string
    | `Invalid_salt_length of int
    | `Hash_failure of string
    | `Verify_mismatch
    | `Invalid_hash of string
    ]

  val pp_error : Format.formatter -> error -> unit

  type params =
    { t_cost : int
    ; m_cost : int
    ; parallelism : int
    }

  val default_params : params

  val hash_with_salt :
     salt:string
    -> params:params
    -> string
    -> (hash, error) result

  val hash : ?params:params -> string -> (hash, error) result
  val verify : hash:hash -> string -> (bool, error) result
end
