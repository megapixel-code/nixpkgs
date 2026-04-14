{
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "pascal-language-server";
  version = "01-02-2026";

  src = fetchFromGitHub {
    owner = "genericptr";
    repo = "pascal-language-server";
    rev = "80064e2a917596dc3a8b661ef2d13ba02bf7a020";
    hash = "";
  };
})
