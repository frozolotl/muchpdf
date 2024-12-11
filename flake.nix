{
  description = "Build a cargo project without extra checks";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    systems.url = "github:nix-systems/default";
    emscripten = {
      url = "github:emscripten-core/emscripten?rev=a1fe3902bf73a3802eae0357d273d0e37ea79898";
      flake = false;
    };
    mupdf = {
      url = "https://mupdf.com/downloads/archive/mupdf-1.24.9-source.tar.gz";
      flake = false;
    };
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = import inputs.systems;

      perSystem =
        { lib, pkgs, ... }:
        let
          stdenv = pkgs.stdenvNoCC;

          emscripten = pkgs.emscripten.overrideAttrs (prevAttrs: {
            version = "3.1.64-fork";
            src = inputs.emscripten;
            # Don't run (failing) tests.
            installPhase = builtins.replaceStrings ["python test/runner.py test_hello_world"] [""] prevAttrs.installPhase;
          });
          mupdf = stdenv.mkDerivation (finalAttrs: {
            version = "1.24.9";
            pname = "mupdf";

            src = inputs.mupdf;

            postPatch = ''
              substituteInPlace Makerules --replace-fail "(shell pkg-config" "(shell $PKG_CONFIG"

              # fix libclang unnamed struct format
              for wrapper in ./scripts/wrap/{cpp,state}.py; do
                substituteInPlace "$wrapper" --replace-fail 'struct (unnamed' '(unnamed struct'
              done
            '';

            makeFlags = [
              "prefix=$(out)"
              "PKG_CONFIG=${pkgs.pkg-config}/bin/${pkgs.pkg-config.targetPrefix}pkg-config"
              "HAVE_X11=no"
              "HAVE_GLUT=no"
              "HAVE_OBJCOPY=no"
            ];

            nativeBuildInputs = [
              emscripten
              pkgs.llvmPackages.bintools
              pkgs.pkg-config
            ];

            configurePhase = ''
              export HOME="$TMPDIR"

              runHook preConfigure
              runHook postConfigure
            '';

            buildPhase = ''
              runHook preBuild

              makeFlagsArray+=(
                -j $NIX_BUILD_CORES
                XCFLAGS="-sSUPPORT_LONGJMP=0 -Os"
              )

              emmake make $makeFlags "''${makeFlagsArray[@]}" libs

              runHook postBuild
            '';

            installPhase = ''
              runHook preInstall

              emmake make -j $NIX_BUILD_CORES $makeFlags "''${makeFlagsArray[@]}" install-libs

              mkdir -p "$out/lib/pkgconfig"
              cat >"$out/lib/pkgconfig/mupdf.pc" <<EOF
              prefix=$out
              libdir=\''${prefix}/lib
              includedir=\''${prefix}/include

              Name: mupdf
              Description: Library for rendering PDF documents
              Version: ${finalAttrs.version}
              Libs: -L\''${libdir} -lmupdf -lmupdf-third
              Cflags: -I\''${includedir}
              EOF

              runHook preInstall
            '';

            enableParallelBuilding = true;

            meta = {
              homepage = "https://mupdf.com";
              description = "Lightweight PDF, XPS, and E-book viewer and toolkit written in portable C";
              changelog = "https://git.ghostscript.com/?p=mupdf.git;a=blob_plain;f=CHANGES;hb=${finalAttrs.version}";
              license = lib.licenses.agpl3Plus;
              mainProgram = "mupdf";
            };
          });
        in
        {
          packages.mupdf = mupdf;
          packages.default = stdenv.mkDerivation {
            pname = "muchpdf";
            version = "0.1.0";

            src = ./.;

            nativeBuildInputs = with pkgs; [
              emscripten
              meson
              ninja
              pkg-config
            ];

            mesonFlags = [
              "--cross-file=cross/wasm.txt"
            ];

            preConfigure = ''
              mkdir -p .emscriptencache
              export EM_CACHE=$(mktemp -d)
            '';

            buildInputs = [
              mupdf
            ];
          };

          devShells.default = pkgs.mkShell.override { inherit stdenv; } {
            name = "muchpdf";

            packages = with pkgs; [
              llvmPackages.clang-tools
              typst
            ];
          };
        };
    };
}
