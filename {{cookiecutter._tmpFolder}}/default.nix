{ compiler ? "ghc883" }:

let
  sources = import ./nix/sources.nix;
  pkgs = import sources.nixpkgs {};

  gitignore = pkgs.nix-gitignore.gitignoreSourcePure [ ./.gitignore ];

  myHaskellPackages = pkgs.haskell.packages.${compiler}.override {
    overrides = hself: hsuper: {
      "{{cookiecutter.projectName}}" =
        hself.callCabal2nix
          "{{cookiecutter.projectName}}"
          (gitignore ./.)
          {};
    };
  };

  shell = myHaskellPackages.shellFor {
    packages = p: [
      p."{{cookiecutter.projectName}}"
    ];
    buildInputs = with pkgs.haskellPackages; [
      myHaskellPackages.cabal-install
      ghcid
      ormolu
      hlint
      (import sources.niv {}).niv
      pkgs.nixpkgs-fmt
    ];
    withHoogle = true;
  };

  exe = pkgs.haskell.lib.justStaticExecutables (myHaskellPackages."{{cookiecutter.projectName}}");

  docker = pkgs.dockerTools.buildImage {
    name = "{{cookiecutter.projectName}}";
    config.Cmd = [ "${exe}/bin/{{cookiecutter.projectName}}" ];
  };
in
{
  inherit shell;
  inherit exe;
  inherit docker;
  inherit myHaskellPackages;
  "{{cookiecutter.projectName}}" = myHaskellPackages."{{cookiecutter.projectName}}";
}
