{
  buildDunePackage,
  lib,
  mirage-crypto,
  mirage-crypto-rng,
  alcotest,
  doCheck ? true,
}:

buildDunePackage {
  pname = "passe";
  version = "0.1.0";

  src =
    let
      fs = lib.fileset;
    in
    fs.toSource {
      root = ../..;
      fileset = fs.unions [
        ../../src
        ../../dune-project
        ../../passe.opam
      ];
    };

  # add your dependencies here
  propagatedBuildInputs = [
    mirage-crypto
    mirage-crypto-rng
  ];

  inherit doCheck;

  checkInputs = [ alcotest ];
}
