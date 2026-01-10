final: prev:
let
  ocamlOverlay = final': prev': {
    passe = final'.callPackage ../packages/passe.nix {
      inherit (final.passe) doCheck;
    };
  };
in
{
  ocaml-ng.ocamlPackages_4_14 = prev.ocaml-ng.ocamlPackages_4_14.overrideScope ocamlOverlay;
  ocaml-ng.ocamlPackages_5_2 = prev.ocaml-ng.ocamlPackages_5_2.overrideScope ocamlOverlay;
  ocaml-ng.ocamlPackages_5_3 = prev.ocaml-ng.ocamlPackages_5_3.overrideScope ocamlOverlay;
  ocaml-ng.ocamlPackages_5_4 = prev.ocaml-ng.ocamlPackages_5_4.overrideScope ocamlOverlay;
  ocaml-ng.ocamlPackages = prev.ocaml-ng.ocamlPackages.overrideScope ocamlOverlay;

  passe = final.lib.makeScope final.newScope (self: {
    doCheck = true;
  });
}
