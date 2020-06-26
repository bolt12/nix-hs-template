#! /bin/bash

projectName={{cookiecutter.projectName}}

# Run summoner to generate the project structure
nix-shell summoner.nix --run "summon new $projectName -f .summoner.toml"

# Run lorri
nix-shell -p lorri --run "lorri init"

# Run niv
nix-shell -p niv --run "niv init"

#Remove shell.nix created by lorri
rm shell.nix

#Create new nix.shell
echo "(import ./default.nix {}).shell" > shell.nix
