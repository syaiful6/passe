let () =
  Alcotest.run
    "Passe test"
    (List.flatten [ Test_bcrypt.tests; Test_argon2.tests ])
