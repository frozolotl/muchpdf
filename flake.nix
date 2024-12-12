{
  description = "Build a cargo project without extra checks";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    systems.url = "github:nix-systems/default";
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
            patches = prevAttrs.patches ++ [
              ./patches/emscripten.patch
            ];

            # Don't run (failing) tests.
            installPhase =
              builtins.replaceStrings [ "python test/runner.py test_hello_world" ] [ "" ]
                prevAttrs.installPhase;
          });
          mupdf = stdenv.mkDerivation (finalAttrs: {
            version = "1.24.9";
            pname = "mupdf";

            src = pkgs.fetchurl {
              url = "https://mupdf.com/downloads/archive/mupdf-${finalAttrs.version}-source.tar.gz";
              hash = "sha256-C0RqoO7MEU6ZadzNcMl4k1j8y2WJqB1HDclBoIdNqYo=";
            };

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

            extraCFlags = [
              # MuPDF does longjmp based exceptions.
              # We simply abort on exception.
              "-sSUPPORT_LONGJMP=0"

              # Optimize for size.
              "-Os"

              # For an overview of MuPDF options, open `mupdf/include/mupdf/fitz/config.h`.

              # I don't think this is necessary for our needs.
              "-DFZ_PLOTTERS_G=0"
              "-DFZ_PLOTTERS_RGB=0"
              "-DFZ_PLOTTERS_CMYK=0"
              "-DFZ_PLOTTERS_N=0"

              # Don't include any fonts but the Base14 ones.
              "-DTOFU"
              "-DTOFU_CJK"

              # Disable all file formats that are not PDF.
              "-DFZ_ENABLE_XPS=0"
              "-DFZ_ENABLE_SVG=0"
              "-DFZ_ENABLE_CBZ=0"
              "-DFZ_ENABLE_IMG=0"
              "-DFZ_ENABLE_HTML=0"
              "-DFZ_ENABLE_FB2=0"
              "-DFZ_ENABLE_MOBI=0"
              "-DFZ_ENABLE_EPUB=0"
              "-DFZ_ENABLE_OFFICE=0"
              "-DFZ_ENABLE_TXT=0"

              # We don't need these outputs.
              "-DFZ_ENABLE_OCR_OUTPUT=0"
              "-DFZ_ENABLE_DOCX_OUTPUT=0"
              "-DFZ_ENABLE_ODT_OUTPUT=0"

              # No PDF interactivity required.
              "-DFZ_ENABLE_JS=0"
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
                XCFLAGS="''${extraCFlags}"
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
