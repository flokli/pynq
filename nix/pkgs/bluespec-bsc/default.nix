{ fetchFromGitHub, callPackage }:

let
  thoughtpoliceBscSrc = (fetchFromGitHub {
    owner = "thoughtpolice";
    repo = "bsc";
    rev = "293d8345e14cca6915998b651212597945ec1561";
    sha256 = "0hszc4ls5qv0ipnhl2bgvkj7d5brlnxmqllpxnv06zn4fr8d7w0f";
    fetchSubmodules = true;
  });
  bluespec-bsc = (callPackage "${thoughtpoliceBscSrc}/bsc.nix" {
    version = "2020.02-beta1+46-g293d834";
  });
in bluespec-bsc
