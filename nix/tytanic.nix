{
  lib,
  fetchFromGitHub,
  rustPlatform,

  openssl,
  pkg-config,
}:

rustPlatform.buildRustPackage rec {
  pname = "tytanic";
  version = "0.2.2";

  src = fetchFromGitHub {
    owner = "tingerrr";
    repo = "tytanic";
    rev = "v${version}";
    hash = "sha256-/yPRJoQ5Lr75eL5+Vc+2E278og/02CYSEuBBgHO1NnU=";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    openssl
  ];

  cargoLock.lockFile = src + /Cargo.lock;

  meta = {
    description = "A test runner for typst projects";
    homepage = "https://tingerrr.github.io/tytanic/index.html";
    license = lib.licenses.mit;
  };
}
