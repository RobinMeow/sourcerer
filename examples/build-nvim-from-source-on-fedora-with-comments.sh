#!/usr/bin/env bash
set -euo pipefail

sudo dnf install --assumeyes \
	ninja-build cmake gcc make unzip gettext curl

# replace this with the location for your dotfiles
source "$HOME/mydotfiles/path-to/sourcerer.sh"

# this will be called by sourcerer.sh if needed
# it has to be called <name>_build_and_install
# the name is provided as first argument to check_source_state
function neovim_build_and_install() {
	make CMAKE_BUILD_TYPE="RelWithDebInfo"
	sudo make install
}
# also has to be called <name>_installed
# it will be called by sourcerer.sh to determine,
# whether or not the programm is already installed or not
function neovim_installed() {
	command -v nvim >/dev/null 2>&1
}
# will only ever upgrade/downgrade if you change this value.
# or you can override this in your .zshrc/.bashrc.
# Example: if you want to stay on bleeding edge development:
# export NVIM_GITREF="origin/master"
# Example: update to latest stable
# export NVIM_GITREF="origin/stable"
NVIM_GITREF=${NVIM_GITREF:-"v0.12.5"}
check_source_state "neovim" "$NVIM_GITREF"
source_git "https://github.com/neovim/neovim"
