type error =
  [ `Hash_failure
  | `Invalid_cost of string
  | `Invalid_hash of string
  | `Invalid_prefix of string
  | `Invalid_salt_length of int
  | `Salt_generation_failure
  | `Truncated of int
  ]
(** Errors that can occur during hashing and verification. *)

val pp_error : Format.formatter -> error -> unit

val hash_with_salt : salt:string -> string -> (Hash.t, error) result
(** [hash_with_salt ~salt s] hash [s] password with the given
    salt and params. *)

val hash_with_salt_exn : salt:string -> string -> Hash.t
(** [hash_with_salt_exn ~salt ~params s] is the same as [hash_with_salt ~salt ~params s]
    but raises Invalid_argument [s] on error. *)

val hash : ?cost:int -> string -> (Hash.t, error) result
(** [hash ?cost s] hash [s] password with a randomly generated salt and the given cost (or default cost if not provided). *)

val hash_exn : ?cost:int -> string -> Hash.t
(** [hash_exn ?cost s] is the same as [hash ?cost s] but raises Invalid_argument [s] on error. *)

val verify : hash:Hash.t -> string -> (bool, error) result
(** [verify ~hash s] verifies that [s] matches the given [hash]. *)

val verify_exn : hash:Hash.t -> string -> bool
(** [verify_exn ~hash s] is the same as [verify ~hash s] but raises Invalid_argument [s] on error. *)
