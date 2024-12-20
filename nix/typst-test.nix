{
  lib,
  fetchFromGitHub,
  rustPlatform,

  openssl,
  pkg-config,
}:

rustPlatform.buildRustPackage rec {
  pname = "typst-test";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "tingerrr";
    repo = "typst-test";
    rev = "5fd453bd5a2baf7f3b0cb647be039be58d09bc22";
    hash = "sha256-maabeDvUhA5yigXbkRWBnbhRKIbwovRhLxQh9xWUQuo=";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    openssl
  ];

  cargoLock.lockFile = src + /Cargo.lock;
  cargoLock.outputHashes = {
    "typst-dev-assets-0.11.0" = "sha256-sgwAXSNpOcfJHM51xkbGXVaCHjVopbfqG2zygOwVg3A=";
  };

  meta = {
    description = "A test runner for typst projects";
    homepage = "https://tingerrr.github.io/typst-test/index.html";
    license = lib.licenses.mit;
  };
}
