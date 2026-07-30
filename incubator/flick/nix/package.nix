{
  lib,
  stdenvNoCC,
  fetchurl,
  version,
  sha256,
  # The `prebuilt` flake input's store path: normally the empty ./nix/dev-app
  # placeholder, but `bench try` overrides it to a dir holding a locally-built
  # Flick.app when feel-testing a source branch (see flake.nix / nix/dev-app).
  prebuilt,
}:

# Package Flick.app so the rice (and anyone) can install it through Nix instead
# of Homebrew — flick's handle in the flake-lock chain.
#
# Normally we fetch the CI-built release ZIP rather than compiling: flick is an
# Xcode project, and macOS 26 refuses to let a session-less `_nixbld` user apply
# SwiftPM's manifest sandbox, so a from-source Nix build dies at package
# resolution (pounce dodges this only by being plain `swiftc` with zero
# packages). The ZIP is already Developer-ID signed + Apple notarized, which is
# exactly what a stable permissions grant wants — so unpack it verbatim and let
# the rice place it at a fixed path (no re-sign dance).
#
# The one exception is `bench try` feel-testing a source branch: it builds the
# app in your login session (where xcodebuild works) and overrides `prebuilt` to
# that build, so we wrap that .app instead of the release. Same packaging.

let
  # bench points `prebuilt` at a dir containing a freshly-built Flick.app; the
  # placeholder has none, so we fall back to the release ZIP.
  useDev = builtins.pathExists "${prebuilt}/Flick.app";
in

stdenvNoCC.mkDerivation {
  pname = "flick";
  # Tag the dev build so its store path (and the rice's install marker) differ
  # from the release — activation then re-copies when you flip between them.
  version = if useDev then "${version}-dev" else version;

  src =
    if useDev then
      prebuilt
    else
      fetchurl {
        url = "https://github.com/nebelhaus/flick/releases/download/v${version}/flick-v${version}-macos.zip";
        inherit sha256;
      };

  # `ditto` is the macOS-correct copy/unarchive: the release ZIP is written by
  # `ditto -c -k` and carries the code signature + stapled notarization ticket as
  # bundle contents + xattrs; a locally-built .app carries its own signature.
  # Plain `unzip`/`cp` can drop those; ditto preserves them so the app verifies.
  # The release archive holds Flick.app at top level (built with --keepParent).
  unpackPhase = ''
    runHook preUnpack
    if [ -d "$src/Flick.app" ]; then
      /usr/bin/ditto "$src/Flick.app" ./Flick.app   # dev build injected by bench
    else
      /usr/bin/ditto -x -k "$src" .                 # release ZIP
    fi
    runHook postUnpack
  '';

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/Applications
    /usr/bin/ditto Flick.app $out/Applications/Flick.app
    runHook postInstall
  '';

  # Don't let Nix strip or re-sign the signed bundle — any rewrite invalidates
  # the signature the permissions grant depends on.
  dontFixup = true;

  meta = {
    description = "Quiet scriptable notification compositor for macOS";
    homepage = "https://github.com/nebelhaus/flick";
    platforms = lib.platforms.darwin;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
