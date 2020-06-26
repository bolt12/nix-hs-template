let
  pkgs = import <nixpkgs> {};
  summon = pkgs.stdenv.mkDerivation {
    name = "summon-cli-linux";

    src = pkgs.fetchurl {
      url = "https://github.com/kowainik/summoner/releases/download/v2.0.1.1/summon-cli-linux";
      sha256 = "6fd241abfc834d3c55f915eaf9e2927d01da0474e84fff18ebca6d67d0c0c117";
    };

    nativeBuildInputs = [
      pkgs.autoPatchelfHook
    ];

    buildInputs = [
      pkgs.git
      pkgs.gitAndTools.hub
      pkgs.curl
      pkgs.gmp
    ];

    unpackPhase = ''
      :
    '';

    installPhase = ''
      install -m755 -D $src $out/bin/summon
    '';
  };
in
  pkgs.mkShell {
    buildInputs = [
      summon
      pkgs.lorri
      pkgs.niv
    ];
  }
