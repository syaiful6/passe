# Passe - Password hash algorithm

Passe is an OCaml library for hashing and verifying passwords using Bcrypt and Argon2.

## API

For each hashing algorithm, Passe provides functions:

- hash: to hash a password with specified parameters.
- hash_with_salt: to hash a password with a given salt.
- verify: to verify a password against a stored hash.

## License

This library is licensed under the ISC License. See [LICENSE](LICENSE) for details.

### Third-Party Code

This library includes vendored implementations:

- **Argon2** reference implementation (dual-licensed CC0 1.0 Universal / Apache 2.0)
- **Bcrypt** from OpenBSD (ISC License)
- **Blowfish** cipher from OpenBSD (BSD 4-Clause License)

All third-party licenses and attributions are included in the [LICENSE](LICENSE) file.
