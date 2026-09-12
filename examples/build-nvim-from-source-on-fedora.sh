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
NVIM_GITREF=${NVIM_GITREF:-"v0.12.5"}
check_source_state "neovim" "$NVIM_GITREF"
source_git "https://github.com/neovim/neovim"
