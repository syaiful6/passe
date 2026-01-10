type variant =
  | Argon2d
  | Argon2i
  | Argon2id

type error =
  [ `Invalid_time_cost of string
  | `Invalid_memory_cost of string
  | `Invalid_parallelism of string
  | `Invalid_salt_length of int
  | `Hash_failure of string
  | `Verify_mismatch
  | `Invalid_hash of string
  ]

let pp_error fmt = function
  | `Invalid_time_cost s -> Format.fprintf fmt "Invalid time cost: %s" s
  | `Invalid_memory_cost s -> Format.fprintf fmt "Invalid memory cost: %s" s
  | `Invalid_parallelism s -> Format.fprintf fmt "Invalid parallelism: %s" s
  | `Invalid_salt_length n -> Format.fprintf fmt "Invalid salt length: %d" n
  | `Hash_failure s -> Format.fprintf fmt "Hash failure: %s" s
  | `Verify_mismatch ->
    Format.fprintf fmt "Verification failed: password mismatch"
  | `Invalid_hash s -> Format.fprintf fmt "Invalid hash: %s" s

type params =
  { t_cost : int
  ; m_cost : int
  ; parallelism : int
  }

(* Default parameters following OWASP recommendations: - t_cost: 2 iterations -
   m_cost: 19 MiB (19456 KiB) - parallelism: 1 thread *)
let default_params = { t_cost = 2; m_cost = 19456; parallelism = 1 }

(* Minimum and maximum values *)
let min_time_cost = 1
let max_time_cost = 2147483647
let min_memory_cost = 8 (* 8 KiB minimum *)
let max_memory_cost = 2147483647
let min_parallelism = 1
let max_parallelism = 16777215
let min_salt_length = 8

external argon2id_hash_encoded_with_salt_stub :
   int
  -> int
  -> int
  -> string
  -> string
  -> string
  = "argon2id_hash_encoded_with_salt_stub_bytecode"
    "argon2id_hash_encoded_with_salt_stub"

external argon2id_verify_stub : string -> string -> int = "argon2id_verify_stub"

let validate_params params =
  if params.t_cost < min_time_cost || params.t_cost > max_time_cost
  then Error (`Invalid_time_cost (Format.sprintf "%d" params.t_cost))
  else if params.m_cost < min_memory_cost || params.m_cost > max_memory_cost
  then Error (`Invalid_memory_cost (Format.sprintf "%d" params.m_cost))
  else if
    params.parallelism < min_parallelism || params.parallelism > max_parallelism
  then Error (`Invalid_parallelism (Format.sprintf "%d" params.parallelism))
  else Ok ()

let hash_with_salt ~salt ~params plain =
  if String.length salt < min_salt_length
  then Error (`Invalid_salt_length (String.length salt))
  else
    match validate_params params with
    | Error e -> Error e
    | Ok () ->
      let encoded =
        argon2id_hash_encoded_with_salt_stub
          params.t_cost
          params.m_cost
          params.parallelism
          plain
          salt
      in
      if String.length encoded = 0
      then Error (`Hash_failure "Failed to generate hash")
      else Ok (Hash.of_string encoded)

let hash ?(params = default_params) plain =
  match validate_params params with
  | Error e -> Error e
  | Ok () ->
    let salt = Crypto.generate 16 in
    hash_with_salt ~salt ~params plain

let verify ~hash plain =
  let hash_str = Hash.to_string hash in
  if String.length hash_str = 0
  then Error (`Invalid_hash "Empty hash")
  else
    let ret = argon2id_verify_stub hash_str plain in
    (* ARGON2_OK = 0, ARGON2_VERIFY_MISMATCH = -35 *)
    if ret = 0
    then Ok true
    else if ret = -35
    then Ok false
    else Error `Verify_mismatch
