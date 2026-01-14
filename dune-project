(lang dune 3.19)

(name passe)
(documentation "https://syaiful6.github.io/passe/passe/Passe/index.html")

(source
  (github syaiful6/passe))

(license ISC)

(authors
  "Syaiful Bahri <syai.bahri6@gmail.com>")

(maintainers
  "Syaiful Bahri <syai.bahri6@gmail.com>")

(generate_opam_files true)

(package
  (name passe)
  (synopsis "Passe is library for hashing and verifying passwords using bcrypt and argon2 algorithms")
  (description "\
  Passe is library for hashing and verifying passwords using bcrypt and argon2 algorithms. It is designed to be simple, \
  secure, and easy to use in OCaml applications\
  ")
  (depends
    (ocaml (>= 4.14))
    dune
    mirage-crypto
    mirage-crypto-rng
    (alcotest :with-test)
    (odoc :with-doc)))
