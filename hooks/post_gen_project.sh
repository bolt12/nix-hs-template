#! /bin/bash

projectName={{cookiecutter.projectName}}

# Run summoner to generate the project structure
# Run lorri
# Run niv
nix-shell hook.nix --run "summon-tui new $projectName && lorri init && niv init"

# Remove shell.nix created by lorri
rm shell.nix

# Create new nix.shell
echo "(import ./default.nix {}).shell" > shell.nix

# Bring project to top-level
mv $projectName/* .
mv $projectName/.git . || true
mv $projectName/.github . || true
mv $projectName/.gitignore . || true
mv $projectName/.travis.yml . || true
rm -r $projectName hook.nix
