type hash
(** A hashed password. This represent a password that has been put through
 a hashing function. *)

val hash_to_string : hash -> string
(** [hash_to_string h] converts the hash [h] to its string representation *)

val hash_of_string : string -> hash
(** [hash_of_string s] convert the string to its hash representation, this
 function must only be used when you know your string is the result of previous
 operation, eg when you get the string from database. *)

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
  (** [pp_error fmt err] pretty print bcrypt error [err] to formatter [fmt] *)

  val hash_with_salt : salt:string -> string -> (hash, error) result
  (** [hash_with_salt ~salt password] hash the [password] using the given [salt] *)

  val hash : ?cost:int -> string -> (hash, error) result
  (** [hash ?cost password] hash the [password] using the given [cost].
      If no cost is provided, a default cost of 12 is used. *)

  val verify : hash:hash -> string -> (bool, error) result
  (** [verify ~hash password] verify that the [password] matches the given [hash] *)
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
  (** [pp_error fmt err] pretty print bcrypt error [err] to formatter [fmt] *)

  type params =
    { t_cost : int
    ; m_cost : int
    ; parallelism : int
    }

  val default_params : params
  (** default parameters following OWASP recommendations *)

  val hash_with_salt :
     salt:string
    -> params:params
    -> string
    -> (hash, error) result
  (** [hash_with_salt ~salt ~params password] hash the [password] using the given
      [salt] and [params] *)

  val hash : ?params:params -> string -> (hash, error) result
  (** [hash ?params password] hash the [password] using the given [params].
      If no params is provided, default params are used. *)

  val verify : hash:hash -> string -> (bool, error) result
  (** [verify ~hash password] verify that the [password] matches the given [hash] *)
end
