open Passe

let () =
  if Array.length Sys.argv < 3
  then (
    Printf.printf "Usage:\n";
    Printf.printf
      "  Bcrypt generate: verify bcrypt generate <password> [cost]\n";
    Printf.printf "  Bcrypt verify:   verify bcrypt verify <password> <hash>\n";
    Printf.printf
      "  Argon2 generate: verify argon2 generate <password> [t_cost] [m_cost] \
       [parallelism]\n";
    Printf.printf "  Argon2 verify:   verify argon2 verify <password> <hash>\n";
    exit 1)

let algo = Sys.argv.(1)
let command = Sys.argv.(2)

let () =
  match algo, command with
  | "bcrypt", "generate" ->
    if Array.length Sys.argv < 4
    then (
      Printf.printf "Error: password required\n";
      exit 1);
    let password = Sys.argv.(3) in
    let cost =
      if Array.length Sys.argv > 4 then int_of_string Sys.argv.(4) else 4
    in
    (match Bcrypt.hash ~cost password with
    | Ok hash ->
      Printf.printf "OCaml generated hash: %s\n" (hash_to_string hash)
    | Error e ->
      Format.fprintf
        Format.std_formatter
        "Error generating hash: %a\n"
        Bcrypt.pp_error
        e;
      exit 1)
  | "bcrypt", "verify" ->
    if Array.length Sys.argv < 5
    then (
      Printf.printf "Error: password and hash required\n";
      exit 1);
    let password = Sys.argv.(3) in
    let hash = hash_of_string Sys.argv.(4) in
    (match Bcrypt.verify ~hash password with
    | Ok true ->
      Printf.printf "✓ Verification successful\n";
      exit 0
    | Ok false ->
      Printf.printf "✗ Verification failed\n";
      exit 1
    | Error e ->
      Format.fprintf
        Format.std_formatter
        "Error during verification: %a\n"
        Bcrypt.pp_error
        e;
      exit 1)
  | "argon2", "generate" ->
    if Array.length Sys.argv < 4
    then (
      Printf.printf "Error: password required\n";
      exit 1);
    let password = Sys.argv.(3) in
    let t_cost =
      if Array.length Sys.argv > 4 then int_of_string Sys.argv.(4) else 2
    in
    let m_cost =
      if Array.length Sys.argv > 5 then int_of_string Sys.argv.(5) else 19456
    in
    let parallelism =
      if Array.length Sys.argv > 6 then int_of_string Sys.argv.(6) else 1
    in
    let params = { Argon2.t_cost; m_cost; parallelism } in
    (match Argon2.hash ~params password with
    | Ok hash ->
      Printf.printf "OCaml generated hash: %s\n" (hash_to_string hash)
    | Error e ->
      Format.fprintf
        Format.std_formatter
        "Error generating hash: %a\n"
        Argon2.pp_error
        e;
      exit 1)
  | "argon2", "verify" ->
    if Array.length Sys.argv < 5
    then (
      Printf.printf "Error: password and hash required\n";
      exit 1);
    let password = Sys.argv.(3) in
    let hash = hash_of_string Sys.argv.(4) in
    (match Argon2.verify ~hash password with
    | Ok true ->
      Printf.printf "✓ Verification successful\n";
      exit 0
    | Ok false ->
      Printf.printf "✗ Verification failed\n";
      exit 1
    | Error e ->
      Format.fprintf
        Format.std_formatter
        "Error during verification: %a\n"
        Argon2.pp_error
        e;
      exit 1)
  | _ ->
    Printf.printf "Unknown algorithm or command: %s %s\n" algo command;
    exit 1
