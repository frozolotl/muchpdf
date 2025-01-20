{
  description = "MuchPDF allows you to insert PDF files as images into your Typst document";

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
          typst-test = pkgs.callPackage ./nix/typst-test.nix { };

          typstManifest = builtins.fromTOML (builtins.readFile ./typst.toml);
          version = typstManifest.package.version;
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
            pkgs.stdenvNoCC.mkDerivation {
              pname = "muchpdf";
              inherit version;

              src = ./.;

              installPhase = ''
                runHook preInstall

                mkdir $out

                cp ${self'.packages.muchpdf}/lib/muchpdf.wasm $out/muchpdf.wasm
                cp ./typst.toml ./LICENSE ./lib.typ README.md $out

                runHook postInstall
              '';

              doCheck = true;
              nativeCheckInputs = [
                pkgs.typst
                typst-test
              ];
              checkPhase = ''
                runHook preCheck

                ln -s ${self'.packages.muchpdf}/lib/muchpdf.wasm muchpdf.wasm
                typst-test run

                runHook postCheck
              '';
            };

          devShells.default = pkgs.mkShell.override { inherit stdenv; } {
            name = "muchpdf";

            inputsFrom = [
              self'.packages.muchpdf
              self'.packages.publication
            ];

            packages = with pkgs; [
              clang-tools
              typst
              typst-test
            ];
          };
        };
    };
}
