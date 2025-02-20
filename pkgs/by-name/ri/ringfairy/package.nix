{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  openssl,
  stdenv,
  darwin,
}:
rustPlatform.buildRustPackage {
  pname = "ringfairy";
  version = "0.1.2-unstable-2024-05-11";

  src = fetchFromGitHub {
    owner = "k3rs3d";
    repo = "ringfairy";
    rev = "966fe129c72a7ff09f55f22273c1c291780d40cd";
    hash = "sha256-1soTvSjoBSIQBUK21COSmw8EKYcMUBjNs+FNs3jzy/E=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-yoZH1GeQWiv9xQGFb1GRKbPpOKxoXhbLMXtkoiG6zS8=";

  nativeBuildInputs = [ pkg-config ];

  buildInputs =
    [ openssl ]
    ++ lib.optionals stdenv.hostPlatform.isDarwin (
      with darwin.apple_sdk.frameworks;
      [
        Security
        SystemConfiguration
      ]
    );

  meta = {
    description = "Static webring generator in Rust";
    homepage = "https://github.com/k3rs3d/ringfairy";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ uncenter ];
    mainProgram = "ringfairy";
  };
}
