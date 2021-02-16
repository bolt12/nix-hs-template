{ compiler ? "ghc883" }:

let
  # Use 'niv init' to update this
  sources = import ./nix/sources.nix;

  # To update the pinned version of nixpkgs you can use:
  # > niv update nixpkgs
  # Or in order to change the branch being tracked run this command:
  # > niv update nixpkgs -b nixos-19.09
  pkgs = import sources.nixpkgs {};

  # all-hls repository
  # Please be aware to match the same compiler version
  hls = import sources.all-hls { platform = "Linux"; version = "0.8.0"; ghc = "8.8.3"; }; # All parameters are optional. The default values are shown here.

  gitignore = pkgs.nix-gitignore.gitignoreSourcePure [ ./.gitignore ];

  # To add external sources with 'niv' from Hackage do the following:
  # > niv add <name> --version <version> -a name=<name> \
  # -t 'https://hackage.haskell.org/package/<name>-<version>/<name>-<version>.tar.gz'
  #
  # You can also add from GitHub specific version like so:
  # > niv add <user>/<repo> -a rev=e3a65cd986805948687d9450717efe00ff01e3b5
  #
  # The sources you pull down with 'niv' are accessible under sources.<name>
  # (fyi: <name> is the key in sources.json)

  # This let's you override any haskell package. Enable/disable tests or
  # haddock generation, change package version, etc..
  myHaskellPackages = pkgs.haskell.packages.${compiler}.override {
    overrides = hself: hsuper: {
      "{{cookiecutter.projectName}}" =
        hself.callCabal2nix
          "{{cookiecutter.projectName}}"
          (gitignore ./.)
          {};
      # Override examples:

      # Override ghcide and some of its dependencies since the versions on
      # Nixpkgs is currently broken.
      #
      # ghcide = pkgs.haskell.lib.dontCheck (hself.callCabal2nix
      #   "ghcide"
      #   (builtins.fetchGit {
      #     url = "https://github.com/digital-asset/ghcide.git";
      #     rev = "0838dcbbd139e87b0f84165261982c82ca94fd08";
      #   })
      #   {});

      # Example of overriding a package with a version known by Nixpkgs.
      # hedgehog = hself.callHackage "hedgehog" "1.0" {};

      # Example of importing a package from Hackage without using the list of
      # packages in Nixpkgs. This requires us to specify the SHA256.
      #
      # morph = hself.callHackageDirect {
      #   pkg = "morph";
      #   ver = "0.1.1.3";
      #   sha256 = "1pax8zx2frj4fldjiqicq8c6pm4j5xmldrlapxaww7422irp51n0";
      # } {};

      # Same example as above but we added the external source from Hackage
      # with 'niv'. And let callCabal2nix handle everything.
      # This is the preferred method.
      #
      # morph =
      #   hself.callCabal2nix
      #     "morph"
      #     sources.morph
      #     {};

      # Same example as above but we added the external source from Hackage
      # with 'niv'. We don't have to specify the SHA256 manually, 'niv' handles
      # it for us.
      #
      # morph = hself.callHackageDirect {
      #   pkg = sources.morph.name;
      #   ver = sources.morph.name;
      #   sha256 = sources.morph.sha256;
      # } {};

      # Example of importing a package from GitHub.
      # This library is in a subdirectory of the repository and the
      # documentation and tests for that commit is broken so we skip generating it.
      #
      # The haskell.lib library includes a number of functions for checking for
      # various imperfections in Haskell packages.
      #
      # eventsourcing =
      #   let
      #     eventsourcingRepo = builtins.fetchGit {
      #       url = "https://github.com/thoferon/eventsourcing.git";
      #       rev = "6647c61af09d80154f58e858c1a5724144955b34";
      #     };
      #   in
      #   pkgs.haskell.lib.dontCheck (pkgs.haskell.lib.dontHaddock (hself.callCabal2nix
      #     "eventsourcing"
      #     (eventsourcingRepo + /eventsourcing)
      #     {}));

      # Lets say you wanted to add extra as dependency of your project and its not in
      # the package set by default:
      #
      # hedgehog = self.haskell.lib.dontCheck (hself.callCabal2nix
      #   "hedgehog"
      #   /absolute/path/to/project/haskell-hedgehog/hedgehog
      #   {});
    };
  };

  # For some packages, like extra we don't need its documentation or setup for profiling
  # since its just a dependency of a build tool. You can speed up building dependencies
  # with a modified package set:
  #
  # fastHaskellPackages = pkgs.haskell.packages.${compiler}.override {
  #     overrides = hself: hsuper: rec {
  #       mkDerivation = args: hsuper.mkDerivation (args // {
  #         doCheck = false;
  #         doHaddock = false;
  #         enableLibraryProfiling = false;
  #         enableExecutableProfiling = false;
  #         jailbreak = true;
  #       });
  #     };
  #   };

  # Returns a derivation whose environment contains a GHC with only
  # the dependencies of packages listed in `packages`, not the
  # packages themselves. Using nix-shell on this derivation will
  # give you an environment suitable for developing the listed
  # packages with an incremental tool like cabal-install.
  # In addition to the "packages" arg and "withHoogle" arg, anything that
  # can be passed into stdenv.mkDerivation can be included in the input attrset
  shell = myHaskellPackages.shellFor {
    packages = p: [
      p."{{cookiecutter.projectName}}"
    ];
    buildInputs = [
      pkgs.haskellPackages.cabal-install
      pkgs.lorri
      (import sources.niv {}).niv
      pkgs.nixpkgs-fmt
      hls
    ];
    withHoogle = true;
  };

  stack = pkgs.haskell.lib.buildStackProject {
    name = "{{cookiecutter.projectName}}";
    buildInputs = with pkgs.haskellPackages; [
      pkgs.haskellPackages.cabal-install
      pkgs.lorri
      (import sources.niv {}).niv
      pkgs.nixpkgs-fmt
      hls
    ];
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
  inherit stack;
  inherit docker;
  inherit myHaskellPackages;
  "{{cookiecutter.projectName}}" = myHaskellPackages."{{cookiecutter.projectName}}";
}
