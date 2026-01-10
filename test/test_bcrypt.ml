open Passe

let test_verify_correct_password () =
  let hash =
    hash_of_string
      "$2a$04$UuTkLRZZ6QofpDOlMz32MuuxEHA43WOemOYHPz6.SjsVsyO1tDU96"
  in
  let password = "password" in
  match Bcrypt.verify ~hash password with
  | Ok true -> ()
  | Ok false -> Alcotest.fail "Password should have matched"
  | Error e ->
    Alcotest.failf "Verification failed with error: %a" Bcrypt.pp_error e

let test_verify_correct_password_2b () =
  let hash =
    hash_of_string
      "$2b$04$EGdrhbKUv8Oc9vGiXX0HQOxSg445d458Muh7DAHskb6QbtCvdxcie"
  in
  let password = "correctbatteryhorsestapler" in
  match Bcrypt.verify ~hash password with
  | Ok true -> ()
  | Ok false -> Alcotest.fail "Password should have matched"
  | Error e ->
    Alcotest.failf "Verification failed with error: %a" Bcrypt.pp_error e

let test_verify_correct_password_2a_variant2 () =
  let hash =
    hash_of_string
      "$2a$04$n4Uy0eSnMfvnESYL.bLwuuj0U/ETSsoTpRT9GVk5bektyVVa5xnIi"
  in
  let password = "correctbatteryhorsestapler" in
  match Bcrypt.verify ~hash password with
  | Ok true -> ()
  | Ok false -> Alcotest.fail "Password should have matched"
  | Error e ->
    Alcotest.failf "Verification failed with error: %a" Bcrypt.pp_error e

let test_verify_wrong_password () =
  let hash =
    hash_of_string
      "$2b$04$EGdrhbKUv8Oc9vGiXX0HQOxSg445d458Muh7DAHskb6QbtCvdxcie"
  in
  let password = "wrong" in
  match Bcrypt.verify ~hash password with
  | Ok false -> ()
  | Ok true -> Alcotest.fail "Wrong password should not have matched"
  | Error e ->
    Alcotest.failf "Verification failed with error: %a" Bcrypt.pp_error e

let test_verify_special_chars () =
  let hash =
    hash_of_string
      "$2b$05$HlFShUxTu4ZHHfOLJwfmCeDj/kuKFKboanXtDJXxCC7aIPTUgxNDe"
  in
  let password = "My S3cre7 P@55w0rd!" in
  match Bcrypt.verify ~hash password with
  | Ok true -> ()
  | Ok false -> Alcotest.fail "Password should have matched"
  | Error e ->
    Alcotest.failf "Verification failed with error: %a" Bcrypt.pp_error e

let test_verify_2y_variant () =
  let hash =
    hash_of_string
      "$2y$12$L6Bc/AlTQHyd9liGgGEZyOFLPHNgyxeEPfgYfBCVxJ7JIlwxyVU3u"
  in
  let password = "testpassword" in
  match Bcrypt.verify ~hash password with
  | Ok _ -> ()
  | Error e ->
    Alcotest.failf "Verification failed with error: %a" Bcrypt.pp_error e

let test_hash_and_verify () =
  let password = "testpassword123" in
  match Bcrypt.hash ~cost:4 password with
  | Error e -> Alcotest.failf "Hash generation failed: %a" Bcrypt.pp_error e
  | Ok hash ->
    (match Bcrypt.verify ~hash password with
    | Ok true -> ()
    | Ok false -> Alcotest.fail "Generated hash should verify correct password"
    | Error e -> Alcotest.failf "Verification failed: %a" Bcrypt.pp_error e)

let test_hash_wrong_password () =
  let password = "correctpassword" in
  match Bcrypt.hash ~cost:4 password with
  | Error e -> Alcotest.failf "Hash generation failed: %a" Bcrypt.pp_error e
  | Ok hash ->
    (match Bcrypt.verify ~hash "wrongpassword" with
    | Ok false -> ()
    | Ok true -> Alcotest.fail "Wrong password should not verify"
    | Error e -> Alcotest.failf "Verification failed: %a" Bcrypt.pp_error e)

let test_password_too_long () =
  let password = String.make 73 'a' in
  match Bcrypt.hash ~cost:4 password with
  | Error (`Truncated 72) -> ()
  | Ok _ -> Alcotest.fail "Should have rejected password longer than 72 chars"
  | Error e -> Alcotest.failf "Wrong error: %a" Bcrypt.pp_error e

let test_password_max_length () =
  let password = String.make 72 'a' in
  match Bcrypt.hash ~cost:4 password with
  | Ok hash ->
    (match Bcrypt.verify ~hash password with
    | Ok true -> ()
    | Ok false -> Alcotest.fail "Max length password should verify"
    | Error e -> Alcotest.failf "Verification failed: %a" Bcrypt.pp_error e)
  | Error e -> Alcotest.failf "Hash generation failed: %a" Bcrypt.pp_error e

let test_invalid_hash_too_short () =
  let hash = hash_of_string "$2a$04$tooshort" in
  let password = "password" in
  match Bcrypt.verify ~hash password with
  | Error (`Invalid_hash _) -> ()
  | Ok _ -> Alcotest.fail "Should have rejected invalid hash"
  | Error e -> Alcotest.failf "Wrong error type: %a" Bcrypt.pp_error e

let test_invalid_hash_bad_prefix () =
  let hash =
    hash_of_string
      "$9z$04$UuTkLRZZ6QofpDOlMz32MuuxEHA43WOemOYHPz6.SjsVsyO1tDU96"
  in
  let password = "password" in
  match Bcrypt.verify ~hash password with
  | Error (`Invalid_prefix _) -> ()
  | Ok _ -> Alcotest.fail "Should have rejected invalid prefix"
  | Error e -> Alcotest.failf "Wrong error type: %a" Bcrypt.pp_error e

let test_cost_validation () =
  (match Bcrypt.hash ~cost:3 "password" with
  | Error (`Invalid_cost _) -> ()
  | Ok _ -> Alcotest.fail "Should reject cost < 4"
  | Error e -> Alcotest.failf "Wrong error: %a" Bcrypt.pp_error e);

  match Bcrypt.hash ~cost:32 "password" with
  | Error (`Invalid_cost _) -> ()
  | Ok _ -> Alcotest.fail "Should reject cost > 31"
  | Error e -> Alcotest.failf "Wrong error: %a" Bcrypt.pp_error e

let test_empty_password () =
  let password = "" in
  match Bcrypt.hash ~cost:4 password with
  | Ok hash ->
    (match Bcrypt.verify ~hash password with
    | Ok true -> ()
    | Ok false -> Alcotest.fail "Empty password should verify"
    | Error e -> Alcotest.failf "Verification failed: %a" Bcrypt.pp_error e)
  | Error e -> Alcotest.failf "Hash generation failed: %a" Bcrypt.pp_error e

let tests =
  [ ( "Bcrypt verification"
    , [ Alcotest.test_case
          "verify correct password (2a)"
          `Quick
          test_verify_correct_password
      ; Alcotest.test_case
          "verify correct password (2b)"
          `Quick
          test_verify_correct_password_2b
      ; Alcotest.test_case
          "verify correct password (2a variant 2)"
          `Quick
          test_verify_correct_password_2a_variant2
      ; Alcotest.test_case
          "verify wrong password"
          `Quick
          test_verify_wrong_password
      ; Alcotest.test_case
          "verify special characters"
          `Quick
          test_verify_special_chars
      ; Alcotest.test_case "verify 2y variant" `Quick test_verify_2y_variant
      ] )
  ; ( "Bcrypt hashing"
    , [ Alcotest.test_case "hash and verify" `Quick test_hash_and_verify
      ; Alcotest.test_case "hash wrong password" `Quick test_hash_wrong_password
      ; Alcotest.test_case "empty password" `Quick test_empty_password
      ] )
  ; ( "Bcrypt validation"
    , [ Alcotest.test_case "password too long" `Quick test_password_too_long
      ; Alcotest.test_case "password max length" `Quick test_password_max_length
      ; Alcotest.test_case
          "invalid hash too short"
          `Quick
          test_invalid_hash_too_short
      ; Alcotest.test_case
          "invalid hash bad prefix"
          `Quick
          test_invalid_hash_bad_prefix
      ; Alcotest.test_case "cost validation" `Quick test_cost_validation
      ] )
  ]
