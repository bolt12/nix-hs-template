#! /bin/bash

projectName={{cookiecutter.projectName}}

# Run summoner to generate the project structure
nix-shell -f '<nixpkgs>' -pA haskellPackages.summoner --run "summon new $projectName -f summoner.toml"

# Run lorri
nix-shell -f '<nixpkgs>' -pA lorri --run "lorri init"

# Run niv
nix-shell -f '<nixpkgs>' -pA niv --run "niv init"

#Remove shell.nix created by lorri
rm shell.nix

#Create new nix.shell
echo "(import ./default.nix {}).shell" > shell.nix

# Move project folder to top level and remove tmpFolder
mv $projectName ../$projectName
cd ..
rm -r tmpFolder
