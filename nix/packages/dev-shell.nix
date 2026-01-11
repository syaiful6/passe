{
  mkShell,
  treefmt,
  ocamlPackages,
  python3,
}:
let
  pythonWithPackages = python3.withPackages (
    ps: with ps; [
      bcrypt
      argon2-cffi
    ]
  );
in
mkShell {
  inputsFrom = with ocamlPackages; [
    passe
  ];
  buildInputs =
    (with ocamlPackages; [
      dune-release
      ocaml-lsp
      ocamlformat
      utop
    ])
    ++ [
      treefmt
      pythonWithPackages
    ];
}
