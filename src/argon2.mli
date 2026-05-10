type error =
  [ `Invalid_time_cost of string
  | `Invalid_memory_cost of string
  | `Invalid_parallelism of string
  | `Invalid_salt_length of int
  | `Hash_failure of string
  | `Verify_mismatch
  | `Invalid_hash of string
  ]
(** Errors that can occur during hashing and verification. *)

val pp_error : Format.formatter -> error -> unit

type params =
  { t_cost : int (* time cost (iterations) *)
  ; m_cost : int (* memory cost in KiB *)
  ; parallelism : int (* number of threads *)
  }

val default_params : params

val hash_with_salt :
   salt:string
  -> params:params
  -> string
  -> (Hash.t, error) result
(** [hash_with_salt ~salt ~params s] hash [s] password with the given
    salt and params. *)

val hash_with_salt_exn : salt:string -> params:params -> string -> Hash.t
(** [hash_with_salt_exn ~salt ~params s] is the same as [hash_with_salt ~salt ~params s]
    but raises Invalid_argument [s] on error. *)

val hash : ?params:params -> string -> (Hash.t, error) result
(** [hash ?params s] hash [s] password with a randomly generated salt and the given params (or default params if not provided). *)

val hash_exn : ?params:params -> string -> Hash.t
(** [hash_exn ?params s] is the same as [hash ?params s] but raises Invalid_argument [s] on error. *)

val verify : hash:Hash.t -> string -> (bool, error) result
(** [verify ~hash s] verifies that [s] matches the given [hash]. *)

val verify_exn : hash:Hash.t -> string -> bool
(** [verify_exn ~hash s] is the same as [verify ~hash s] but raises Invalid_argument [s] on error. *)
