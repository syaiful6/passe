open Passe

let test_hash_and_verify () =
  let password = "testpassword123" in
  let params = { Argon2.t_cost = 2; m_cost = 4096; parallelism = 1 } in
  match Argon2.hash ~params password with
  | Error e -> Alcotest.failf "Hash generation failed: %a" Argon2.pp_error e
  | Ok hash ->
    (match Argon2.verify ~hash password with
    | Ok true -> ()
    | Ok false -> Alcotest.fail "Generated hash should verify correct password"
    | Error e -> Alcotest.failf "Verification failed: %a" Argon2.pp_error e)

let test_hash_wrong_password () =
  let password = "correctpassword" in
  let params = { Argon2.t_cost = 2; m_cost = 4096; parallelism = 1 } in
  match Argon2.hash ~params password with
  | Error e -> Alcotest.failf "Hash generation failed: %a" Argon2.pp_error e
  | Ok hash ->
    (match Argon2.verify ~hash "wrongpassword" with
    | Ok false -> ()
    | Ok true -> Alcotest.fail "Wrong password should not verify"
    | Error e -> Alcotest.failf "Verification failed: %a" Argon2.pp_error e)

let test_default_params () =
  let password = "testpassword" in
  match Argon2.hash password with
  | Error e -> Alcotest.failf "Hash generation failed: %a" Argon2.pp_error e
  | Ok hash ->
    (match Argon2.verify ~hash password with
    | Ok true -> ()
    | Ok false -> Alcotest.fail "Hash with default params should verify"
    | Error e -> Alcotest.failf "Verification failed: %a" Argon2.pp_error e)

let test_empty_password () =
  let password = "" in
  let params = { Argon2.t_cost = 2; m_cost = 4096; parallelism = 1 } in
  match Argon2.hash ~params password with
  | Ok hash ->
    (match Argon2.verify ~hash password with
    | Ok true -> ()
    | Ok false -> Alcotest.fail "Empty password should verify"
    | Error e -> Alcotest.failf "Verification failed: %a" Argon2.pp_error e)
  | Error e -> Alcotest.failf "Hash generation failed: %a" Argon2.pp_error e

let test_long_password () =
  let password = String.make 200 'a' in
  let params = { Argon2.t_cost = 2; m_cost = 4096; parallelism = 1 } in
  match Argon2.hash ~params password with
  | Ok hash ->
    (match Argon2.verify ~hash password with
    | Ok true -> ()
    | Ok false -> Alcotest.fail "Long password should verify"
    | Error e -> Alcotest.failf "Verification failed: %a" Argon2.pp_error e)
  | Error e -> Alcotest.failf "Hash generation failed: %a" Argon2.pp_error e

let test_special_chars () =
  let password = "My S3cre7 P@55w0rd! 🔐" in
  let params = { Argon2.t_cost = 2; m_cost = 4096; parallelism = 1 } in
  match Argon2.hash ~params password with
  | Ok hash ->
    (match Argon2.verify ~hash password with
    | Ok true -> ()
    | Ok false -> Alcotest.fail "Password with special chars should verify"
    | Error e -> Alcotest.failf "Verification failed: %a" Argon2.pp_error e)
  | Error e -> Alcotest.failf "Hash generation failed: %a" Argon2.pp_error e

let test_invalid_time_cost () =
  let password = "password" in
  (match
     Argon2.hash ~params:{ t_cost = 0; m_cost = 4096; parallelism = 1 } password
   with
  | Error (`Invalid_time_cost _) -> ()
  | Ok _ -> Alcotest.fail "Should reject t_cost < 1"
  | Error e -> Alcotest.failf "Wrong error: %a" Argon2.pp_error e);
  ()

let test_invalid_memory_cost () =
  let password = "password" in
  match
    Argon2.hash ~params:{ t_cost = 2; m_cost = 7; parallelism = 1 } password
  with
  | Error (`Invalid_memory_cost _) -> ()
  | Ok _ -> Alcotest.fail "Should reject m_cost < 8"
  | Error e -> Alcotest.failf "Wrong error: %a" Argon2.pp_error e

let test_invalid_parallelism () =
  let password = "password" in
  match
    Argon2.hash ~params:{ t_cost = 2; m_cost = 4096; parallelism = 0 } password
  with
  | Error (`Invalid_parallelism _) -> ()
  | Ok _ -> Alcotest.fail "Should reject parallelism < 1"
  | Error e -> Alcotest.failf "Wrong error: %a" Argon2.pp_error e

let test_salt_too_short () =
  let password = "password" in
  let params = { Argon2.t_cost = 2; m_cost = 4096; parallelism = 1 } in
  let short_salt = "short" in
  match Argon2.hash_with_salt ~salt:short_salt ~params password with
  | Error (`Invalid_salt_length _) -> ()
  | Ok _ -> Alcotest.fail "Should reject salt < 8 bytes"
  | Error e -> Alcotest.failf "Wrong error: %a" Argon2.pp_error e

let test_different_params_different_hashes () =
  let password = "testpassword" in
  let params1 = { Argon2.t_cost = 2; m_cost = 4096; parallelism = 1 } in
  let params2 = { Argon2.t_cost = 3; m_cost = 4096; parallelism = 1 } in
  match
    Argon2.hash ~params:params1 password, Argon2.hash ~params:params2 password
  with
  | Ok hash1, Ok hash2 ->
    if hash_to_string hash1 = hash_to_string hash2
    then Alcotest.fail "Different params should produce different hashes"
  | Error e, _ | _, Error e ->
    Alcotest.failf "Hash generation failed: %a" Argon2.pp_error e

let test_verify_with_null_byte_in_hash () =
  let hash = hash_of_string "$argon2id$v=19\000$m=4096,t=2,p=1$invalid" in
  let password = "password" in
  match Argon2.verify ~hash password with
  | exception Invalid_argument msg ->
    if String.sub msg 0 7 = "argon2:"
    then ()
    else Alcotest.failf "Expected argon2 error but got: %s" msg
  | Ok _ ->
    Alcotest.fail "Should have raised Invalid_argument for hash with null byte"
  | Error e -> Alcotest.failf "Wrong error type: %a" Argon2.pp_error e

let tests =
  [ ( "Argon2 hashing"
    , [ Alcotest.test_case "hash and verify" `Quick test_hash_and_verify
      ; Alcotest.test_case "hash wrong password" `Quick test_hash_wrong_password
      ; Alcotest.test_case "default params" `Quick test_default_params
      ; Alcotest.test_case "empty password" `Quick test_empty_password
      ; Alcotest.test_case "long password" `Quick test_long_password
      ; Alcotest.test_case "special characters" `Quick test_special_chars
      ; Alcotest.test_case
          "different params produce different hashes"
          `Quick
          test_different_params_different_hashes
      ] )
  ; ( "Argon2 validation"
    , [ Alcotest.test_case "invalid time cost" `Quick test_invalid_time_cost
      ; Alcotest.test_case "invalid memory cost" `Quick test_invalid_memory_cost
      ; Alcotest.test_case "invalid parallelism" `Quick test_invalid_parallelism
      ; Alcotest.test_case "salt too short" `Quick test_salt_too_short
      ] )
  ; ( "Argon2 security"
    , [ Alcotest.test_case
          "verify with null byte in hash"
          `Quick
          test_verify_with_null_byte_in_hash
      ] )
  ]
