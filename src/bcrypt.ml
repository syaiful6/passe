module Variant = struct
  type t =
    | A
    | Y
    | B

  let pp fmt = function
    | A -> Format.fprintf fmt "2a"
    | Y -> Format.fprintf fmt "2y"
    | B -> Format.fprintf fmt "2b"

  let of_raw_string = function
    | "$2a$" -> Some A
    | "$2y$" -> Some Y
    | "$2b$" -> Some B
    | _ -> None

  let to_string = Format.asprintf "%a" pp
end

type error =
  [ `Truncated of int
  | `Invalid_cost of string
  | `Invalid_prefix of string
  | `Invalid_hash of string
  | `Salt_generation_failure
  | `Hash_failure
  | `Invalid_salt_length of int
  ]

let pp_error fmt = function
  | `Truncated n -> Format.fprintf fmt "Password truncated to %d characters" n
  | `Invalid_cost s -> Format.fprintf fmt "Invalid cost: %s" s
  | `Invalid_prefix s -> Format.fprintf fmt "Invalid prefix: %s" s
  | `Invalid_hash s -> Format.fprintf fmt "Invalid hash: %s" s
  | `Salt_generation_failure -> Format.fprintf fmt "Salt generation failure"
  | `Hash_failure -> Format.fprintf fmt "Hash generation failure"
  | `Invalid_salt_length n -> Format.fprintf fmt "Invalid salt length: %d" n

let min_cost = 4
let max_cost = 31
let default_cost = 12

external bcrypt_hash_stub :
   string
  -> string
  -> string
  = "password_bcrypt_hashpass_stub"

external bcrypt_base64_encode : string -> string = "password_encode_base64_stub"

let _hash_password ~salt pswd =
  if String.length pswd > 72
  then Error (`Truncated 72)
  else
    let hash = bcrypt_hash_stub pswd salt in
    Ok hash

let is_salt_valid salt =
  let revision = String.sub salt 0 4 in
  match Variant.of_raw_string revision with
  | Some _ when String.length salt = 29 -> true
  | None when String.length salt = 22 -> true
  | _ -> false

let hash_with_salt ~salt plain =
  if not (is_salt_valid salt)
  then Error (`Invalid_salt_length (String.length salt))
  else
    let variant_and_salt =
      let variant =
        if String.length salt = 22
        then Some Variant.B (* user provided salt without prefix *)
        else Variant.of_raw_string (String.sub salt 0 4)
      in
      match variant with
      | Some Variant.Y ->
        (* openbsd doesn't support $2y$ *)
        Some (Variant.B, Format.asprintf "$2b$%s" (String.sub salt 4 25))
      | Some variant -> Some (variant, salt)
      | _ -> None
    in
    match variant_and_salt with
    | Some (variant, normalized_salt) ->
      (match _hash_password ~salt:normalized_salt plain with
      | Ok hash when String.length hash = 0 -> Error `Hash_failure
      | Ok hash ->
        Ok
          (Hash.of_string
             (Format.asprintf
                "$%s$%s"
                (Variant.to_string variant)
                (String.sub hash 4 (String.length hash - 4))))
      | Error e -> Error e)
    | None -> Error (`Invalid_prefix salt)

let generate_salt cost variant =
  let cost_str = Printf.sprintf "%02d" cost in
  let salt_bytes = Crypto.generate 16 in
  let salt_b64 = bcrypt_base64_encode salt_bytes in
  if String.length salt_b64 = 0
  then Error `Salt_generation_failure
  else
    Ok
      (Format.asprintf
         "$%s$%s$%s"
         (Variant.to_string variant)
         cost_str
         salt_b64)

let hash ?(cost = default_cost) plain =
  if cost < min_cost || cost > max_cost
  then Error (`Invalid_cost (Format.sprintf "%d" cost))
  else
    Result.bind (generate_salt cost Variant.B) (fun salt ->
      hash_with_salt ~salt plain)

let verify ~hash plain =
  let hash_str = Hash.to_string hash in
  if String.length hash_str <> 60
  then Error (`Invalid_hash hash_str)
  else
    let variant = String.sub hash_str 0 4 |> Variant.of_raw_string in
    match variant with
    | None -> Error (`Invalid_prefix hash_str)
    | Some _ ->
      let hash_salt = String.sub hash_str 0 29 in
      if String.length hash_salt <> 29
      then Error (`Invalid_hash hash_str)
      else (
        match hash_with_salt ~salt:hash_salt plain with
        | Error e -> Error e
        | Ok computed_hash ->
          let is_equal =
            Crypto.constant_time_equal (Hash.to_string computed_hash) hash_str
          in
          Ok is_equal)
