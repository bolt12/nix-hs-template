#! /bin/bash

projectName={{cookiecutter.projectName}}

# Run summoner to generate the project structure
# Run lorri
# Run niv
nix-shell hook.nix --run "summon new $projectName -f .summoner.toml && lorri init && niv init"

# Remove shell.nix created by lorri
rm shell.nix

# Create new nix.shell
echo "(import ./default.nix {}).shell" > shell.nix

# Bring project to top-level
mv $projectName/* . && rm -r $projectName
