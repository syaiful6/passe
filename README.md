# Passe - Password hash algorithm

Passe is an OCaml library for hashing and verifying passwords using Bcrypt and Argon2.

The primary goal of Passe is to provide a simple and secure interface for password hashing,
and easy to install library. All dependencies are vendored, so no external libraries are required.

## Usage

### Argon2

```ocaml
let hash_result = Passe.Argon2.hash "my_password"

match hash_result with
| Ok hash ->
    (* Store the hash in your database *)
    let hash_string = Passe.hash_to_string hash in
    store_in_db hash_string
| Error e ->
    Format.eprintf "%a" Passe.Argon2.pp_error e

(* Verify a password against a stored hash *)
let stored_hash = Passe.hash_of_string (get_from_db ()) in
match Passe.Argon2.verify ~hash:stored_hash "user_input" with
| Ok true -> (* Password matches *)
| Ok false -> (* Password does not match *)
| Error e -> (* Handle error *)

(* Use custom parameters *)
let params = { Passe.Argon2.t_cost = 3; m_cost = 65536; parallelism = 4 } in
let hash_result = Passe.Argon2.hash ~params "my_password"
```

### Bcrypt

```ocaml

let hash_result = Passe.Bcrypt.hash "my_password"

match hash_result with
| Ok hash ->
    let hash_string = Passe.hash_to_string hash in
    store_in_db hash_string
| Error e ->
    Format.eprintf "%a" Passe.Bcrypt.pp_error e

let stored_hash = Passe.hash_of_string (get_from_db ()) in
match Passe.Bcrypt.verify ~hash:stored_hash "user_input" with
| Ok true -> (* Password matches *)
| Ok false -> (* Password does not match *)
| Error e -> (* Handle error *)

(* Use custom cost factor *)
let hash_result = Bcrypt.hash ~cost:14 "my_password"
```

## Examples

The `examples/` directory contains cross-language verification tests that demonstrate
compatibility with Python's `argon2-cffi` and `bcrypt` libraries.

## License

This library is licensed under the ISC License. See [LICENSE](LICENSE) for details.

### Third-Party Code

This library includes vendored implementations:

- **Argon2** reference implementation (dual-licensed CC0 1.0 Universal / Apache 2.0)
- **Bcrypt** from OpenBSD (ISC License)
- **Blowfish** cipher from OpenBSD (BSD 4-Clause License)

All third-party licenses and attributions are included in the [LICENSE](LICENSE) file.
