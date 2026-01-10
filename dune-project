(lang dune 3.19)

(name passe)
(documentation "https://syaiful6.github.io/passe/")

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
  (synopsis "password hashes implementation (bcrypt and argon2)")
  (description "\
  password hashes implementation (bcrypt and argon2)
  ")
  (depends
    (ocaml (>= 5.2))
    dune
    mirage-crypto
    mirage-crypto-rng
    (alcotest :with-test)
    (odoc :with-doc)))
