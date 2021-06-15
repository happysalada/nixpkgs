{ lib
, stdenv
, fetchFromGitHub
, mkYarnModules
, nodejs
, yarn
, git
, callPackage
}:

let

  yarnModules = pname: version: src: mkYarnModules {
    pname = "${pname}-modules";
    inherit version;
    packageJSON = "${src}/package.json";
    yarnLock = ./yarn.lock;
    yarnNix = ./yarn.nix;
    postBuild = ''
      cp -r $out/deps/mattermost-webapp-modules/node_modules/* $out/node_modules/
    '';
  };

  nodeDependencies = (callPackage ./node-deps.nix { }).shell.nodeDependencies;

in

stdenv.mkDerivation rec {
  pname = "mattermost-webapp";
  version = "5.32.1";

  src = fetchFromGitHub {
    owner = "mattermost";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256:1bw3sjk9mfp4jsgmk0jvsj1aklwckrp41xygl3kd8gwp58rdp2l2";
  };

  nativeBuildInputs = [
    git
    nodejs
  ];

  postPatch = ''
    substituteInPlace webpack.config.js --replace \
      "JSON.stringify(childProcess.execSync('git rev-parse HEAD || echo dev').toString())" \
      "\"e73500dab9c9dd584a035340575cf432ac2e50b1\""
  '';

  buildPhase = ''
    ln -s ${nodeDependencies}/lib/node_modules ./node_modules
    export PATH="${nodeDependencies}/bin:$PATH"
    cross-env NODE_ENV=production webpack
  '';

  installPhase = ''
    ls -la
    mv dist $out
  '';

  meta = with lib; {
    description = "Open-source, self-hosted Slack-alternative";
    homepage = "https://www.mattermost.org";
    license = with licenses; [ agpl3 asl20 ];
    maintainers = with maintainers; [ fpletz ryantm ];
    platforms = platforms.unix;
  };

}

# installPhase = ''
#   mkdir -p $out
#   tar --strip 1 --directory $out -xf $src \
#   mattermost/client \
#   mattermost/i18n \
#   mattermost/fonts \
#   mattermost/templates \
#   mattermost/config
# '';
