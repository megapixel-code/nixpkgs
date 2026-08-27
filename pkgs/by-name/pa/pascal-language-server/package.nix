{
  lib,
  stdenv,
  fetchFromGitHub,
  fpc,
  lazarus,
  writableTmpDirAsHomeHook,
  makeWrapper,
  bash,
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
    bash
  ];

  buildPhase = ''
    # chmod +x src/build_fpc.sh
    # LAZARUSDIR=${lazarus}/share/lazarus \
    #   FPC=${fpc}/bin/fpc \
    #   FPC_CFG=${fpc}/etc/fpc.cfg \
    #   bash src/build_fpc.sh
    # TODO: add pr to make build_fpc script responsive to this env var

    lazbuild --lazarusdir=${lazarus}/share/lazarus \
      src/protocol/lspprotocol.lpk \
      src/serverprotocol/lspserver.lpk \
      -B src/standard/pasls.lpr

    # lazbuild --lazarusdir=${lazarus}/share/lazarus \
    #   src/protocol/lspprotocol.lpk \
    #   src/serverprotocol/lspserver.lpk \
    #   src/proxy/paslsproxy.lpi
    #
    # lazbuild --lazarusdir=${lazarus}/share/lazarus \
    #   src/protocol/lspprotocol.lpk \
    #   src/serverprotocol/lspserver.lpk \
    #   src/socketserver/paslssock.lpi
  '';

  installPhase = ''
    mkdir -p "$out/bin"
    mkdir -p "$out/opt"

    cp src/standard/pasls         $out/opt/pasls
    # cp src/socketserver/paslssock $out/bin/paslssock
    # cp src/proxy/paslsproxy       $out/bin/paslsproxy

    makeWrapper "$out/opt/pasls" "$out/bin/pasls"   \
    --prefix FPCDIR : ${fpc}/lib/fpc/${fpc.version} \
    --prefix PP : ${fpc}/bin/fpc                    \
    --prefix LAZARUSDIR : ${lazarus}/share/lazarus

    # FIXME: x86_64-linux replace with correct
    # cp dist/x86_64-linux/pasls "$out/opt/pasls"
  '';

  propagatedBuildInputs = [
    lazarus
    fpc
  ];

  meta = {
    description = "An LSP server implementation for Pascal variants that are supported by Free Pascal, including Object Pascal.";
    homepage = "https://github.com/genericptr/pascal-language-server";
    license = with lib.licenses; [ gpl3 ];
    maintainers = with lib.maintainers; [ megapixel-code ];
    mainProgram = "pasls";
    platforms = lib.platforms.unix;
  };
})
