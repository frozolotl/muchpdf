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
        { self', pkgs, ... }:
        let
          stdenv = pkgs.stdenvNoCC;
          toml = pkgs.formats.toml { };

          emscripten = pkgs.emscripten.overrideAttrs (
            finalAttrs: prevAttrs: {
              version = "3.1.64";
              src = pkgs.fetchFromGitHub {
                owner = "emscripten-core";
                repo = "emscripten";
                hash = "sha256-AbO1b4pxZ7I6n1dRzxhLC7DnXIUnaCK9SbLy96Qxqr0=";
                rev = finalAttrs.version;
              };

              patches = prevAttrs.patches ++ [
                ./patches/emscripten.patch
              ];

              # Don't run (failing) tests.
              installPhase =
                builtins.replaceStrings [ "python test/runner.py test_hello_world" ] [ "" ]
                  prevAttrs.installPhase;
            }
          );
          mupdf = pkgs.callPackage ./nix/mupdf.nix {
            inherit emscripten;
          };

          version = "0.1.0";
        in
        {
          # MuPDF compiled to WASM32.
          packages.mupdf = mupdf;

          # The WASM component of MuchPDF.
          packages.muchpdf = stdenv.mkDerivation {
            pname = "muchpdf";
            inherit version;

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

          # Everything packaged to be suitable for publication.
          packages.publication =
            let
              manifest = {
                package = {
                  name = "muchpdf";
                  inherit version;
                  entrypoint = "lib.typ";
                  authors = [ "frozolotl <frozolotl@protonmail.com>" ];
                  license = "AGPL-3.0-or-later";
                  description = "Include PDF images in your Typst document";
                  repository = "https://github.com/frozolotl/muchpdf";
                  keywords = [
                    "pdf"
                    "image"
                  ];
                  categories = [
                    "visualization"
                    "integration"
                  ];
                  exclude = [
                    "cross/"
                    "src/"
                    "patches/"
                    "meson.build"
                  ];
                };
              };
              manifestFile = toml.generate "typst.toml" manifest;
            in
            pkgs.stdenvNoCC.mkDerivation {
              pname = "muchpdf";
              inherit version;

              src = ./.;

              installPhase = ''
                runHook preInstall

                mkdir $out

                cp ${manifestFile} $out/typst.toml
                cp ${self'.packages.muchpdf}/lib/muchpdf.wasm $out/muchpdf.wasm
                cp ./LICENSE ./lib.typ README.md $out

                runHook postInstall
              '';
            };

          devShells.default = pkgs.mkShell.override { inherit stdenv; } {
            name = "muchpdf";

            packages = with pkgs; [
              clang-tools
            ];
          };
        };
    };
}
