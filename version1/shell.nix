{ nixpkgs ? import <nixpkgs> { }, compiler ? "ghc8107" }:
let
  haskellPackages = nixpkgs.pkgs.haskell.packages.${compiler};
in
haskellPackages.shellFor {
  packages = _: [ (import ./. { inherit nixpkgs compiler; }) ];
  buildInputs = [ haskellPackages.haskell-language-server haskellPackages.cabal-install ];
}
