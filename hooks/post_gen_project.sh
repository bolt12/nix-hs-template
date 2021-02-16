#!/usr/bin/env bash

projectName={{cookiecutter.projectName}}

# Run summoner to generate the project structure
# Run lorri
# Run niv
nix-shell hook.nix --run "summon-tui new $projectName"
nix-shell hook.nix --run "lorri init && niv init"

# Add all-hls to niv
niv add masaeedu/all-hls

# Update niv
niv init
niv update
niv update nixpkgs -b 20.09

# Remove shell.nix created by lorri
rm shell.nix

# Create new nix.shell
echo "(import ./default.nix {}).shell" > shell.nix
echo "(import ./default.nix {}).stack" > stack.nix

# Bring project to top-level
mv $projectName/* .
mv $projectName/.git . || true
mv $projectName/.github . || true
mv $projectName/.gitignore . || true
mv $projectName/.travis.yml . || true
echo "nix:
  enable: true
  shell-file: stack.nix
  " >> stack.yaml || true

rm -r $projectName hook.nix

echo "All done!"
