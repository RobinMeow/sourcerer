#!/usr/bin/env bash
set -euo pipefail

sudo dnf install --assumeyes \
	ninja-build cmake gcc make unzip gettext curl
source "$HOME/mydotfiles/path-to/sourcerer.sh"

function neovim_build_and_install() {
	make CMAKE_BUILD_TYPE="RelWithDebInfo"
	sudo make install
}

function neovim_installed() {
	command -v nvim >/dev/null 2>&1
}
# export SOURCERER_NVIM_GITREV in your .zshrc/.bashrc
# to change this value
SOURCERER_NVIM_GITREV=${SOURCERER_NVIM_GITREV:-"origin/stable"}
check_source_state "neovim" "$SOURCERER_NVIM_GITREV"
source_git "https://github.com/neovim/neovim"
