{
  lib,
  fetchFromGitHub,
  rustPlatform,

  openssl,
  pkg-config,
}:

rustPlatform.buildRustPackage rec {
  pname = "tytanic";
  version = "0.2.1";

  src = fetchFromGitHub {
    owner = "tingerrr";
    repo = "tytanic";
    rev = "v${version}";
    hash = "sha256-WAWifXDTii6Yj5QOpquNMUMNqZq7/tMo1eCg1Ja2LCk=";
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
