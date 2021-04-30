{ lib, fetchFromGitHub, rustPlatform, stdenv, libiconv }:

rustPlatform.buildRustPackage rec {
  pname = "zellij";
  version = "0.6.0";

  src = fetchFromGitHub {
    owner = "zellij-org";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-spESDjX7scihVQrr/f6KMCI9VfdTxxPWP7FcJ965FYk=";
  };

  cargoSha256 = "sha256-AQf9fwBKYXVtDXmVHaFrSCA51K4OQkIDL6gJyZwOo2Y=";

  buildInputs = lib.optionals stdenv.isDarwin [ libiconv ];

  preCheck = ''
    HOME=$TMPDIR
  '';

  meta = with lib; {
    description = "A terminal workspace with batteries included";
    homepage = "https://zellij.dev/";
    license = with licenses; [ mit ];
    maintainers = with maintainers; [ therealansh ];
  };
}
