{ mkDerivation, array, base, containers, directory, filepath, HUnit
, lib, mtl, parsec, pretty, QuickCheck, transformers
, unbound-generics
, fetchFromGitHub
}:
let
  unbound-generics-git = unbound-generics.overrideAttrs (_: {
    src = fetchFromGitHub {
      owner = "lambdageek";
      repo = "unbound-generics";
      rev = "04f940740d95aecd105fd87ed9f49ee0b81da408";
      sha256 = "0jq6pcaj6fvq9sy5i8lmi6kbdykp7c28slk1nw5xfn5jzb2ppvgz";
    };
  });
in
mkDerivation {
  pname = "pi-forall";
  version = "0.2";
  src = ./.;
  isLibrary = true;
  isExecutable = true;
  libraryHaskellDepends = [
    array base containers directory filepath HUnit mtl parsec pretty
    QuickCheck transformers unbound-generics-git
  ];
  executableHaskellDepends = [
    array base containers directory filepath HUnit mtl parsec pretty
    QuickCheck transformers unbound-generics-git
  ];
  testHaskellDepends = [
    array base containers directory filepath HUnit mtl parsec pretty
    QuickCheck transformers unbound-generics-git
  ];
  homepage = "https://github.com/sweirich/pi-forall";
  description = "Demo implementation of typechecker for dependently-typed language";
  license = lib.licenses.bsd3;
}
