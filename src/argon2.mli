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

val hash : ?params:params -> string -> (Hash.t, error) result
val verify : hash:Hash.t -> string -> (bool, error) result
