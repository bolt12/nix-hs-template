let
  pkgs = import <nixpkgs> {};
  summon = pkgs.stdenv.mkDerivation {
    name = "summon-cli-linux";

    src = pkgs.fetchurl {
      url = "https://github.com/kowainik/summoner/releases/download/v2.0.1.1/summon-tui-linux";
      sha256 = "25c12dfbad5d967c5f3a9c5bc7cf9364dbb7e9a95b83b1ae6b84339afccd6018";
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
      install -m755 -D $src $out/bin/summon-tui
    '';
  };
in
  pkgs.mkShell {
    buildInputs = [
      summon-tui
      pkgs.lorri
      pkgs.niv
    ];
  }
