{
  mkShell,
  treefmt,
  ocamlPackages,
}:
mkShell {
  inputsFrom = with ocamlPackages; [
    passe
  ];
  buildInputs =
    (with ocamlPackages; [
      ocaml-lsp
      ocamlformat
      utop
    ])
    ++ [
      treefmt
    ];
}
