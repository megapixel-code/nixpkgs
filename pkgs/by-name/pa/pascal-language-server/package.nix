{
  lib,
  stdenv,
  fetchFromGitHub,
  fpc,
  lazarus,
  writableTmpDirAsHomeHook,
  makeWrapper,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "pascal-language-server";
  version = "01-02-2026";

  src = fetchFromGitHub {
    owner = "genericptr";
    repo = "pascal-language-server";
    rev = "80064e2a917596dc3a8b661ef2d13ba02bf7a020";
    hash = "sha256-0GG8zEP2JCyWM5LQCWAvuVL6pIuRQMYrvrmsZ7HL9hE=";
  };

  nativeBuildInputs = [
    fpc
    lazarus
    writableTmpDirAsHomeHook # lazarus tries to create files in $HOME/.lazarus
    makeWrapper
  ];

  buildPhase = ''
    lazbuild --lazarusdir=${lazarus}/share/lazarus \
      src/protocol/lspprotocol.lpk \
      src/serverprotocol/lspserver.lpk \
      src/standard/pasls.lpi
  '';

  installPhase = ''
    mkdir -p $out/bin
    makeWrapper src/standard/pasls $out/bin/pasls \
      --prefix PP=${fpc}/bin/fpc \
      --prefix FPCDIR=${fpc} \
      --prefix LAZARUSDIR=${lazarus}
  '';

  meta = {
    description = "An LSP server implementation for Pascal variants that are supported by Free Pascal, including Object Pascal.";
    homepage = "https://github.com/genericptr/pascal-language-server";
    license = with lib.licenses; [ gpl3 ];
    maintainers = with lib.maintainers; [ megapixel-code ];
    mainProgram = "pasls";
    platforms = lib.platforms.unix;
  };
})
