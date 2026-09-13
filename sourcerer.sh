#!/usr/bin/env bash
set -euo pipefail

NC="\033[0m" # No Color

RED="\033[38;5;203m" # #f38ba8

sourcerer_error() {
	echo -e "${RED}[ERROR]${NC} $*"
}

# ORANGE="\033[38;5;215m" # #fab387
# warn() {
# 	echo -e "${ORANGE}[WARN]${NC} $*"
# }

# GREEN="\033[38;5;114m"  # #a6e3a1
# success() {
# 	echo -e "${GREEN}[SUCCESS]${NC} $*"
# }

BLUE="\033[38;5;109m" # #89b4fa
sourcerer_info() {
	echo -e "${BLUE}[INFO]${NC} $*"
}

SOURCE=${SOURCERER_DEST:-"$HOME/.local/share/sourcerer"}
mkdir -p "$SOURCE"

function check_source_state() {
	export SOURCE_NAME=${1:?1st arg SOURCE_NAME is required}
	export SOURCE_GITREV=${2:?2nd arg SOURCE_GITREV is required}
	export SOURCE_DEST="$SOURCE/$SOURCE_NAME"

	if [[ -d "$SOURCE_DEST" ]]; then
		# quick and dirty, fetch everything, so we dont have to bother with origin/checks
		# do not use --jobs=10. which will cause gh rate limits to block (not logged in) requests in rare occasions.
		git -C "$SOURCE_DEST" fetch --all --tags --prune

		if [[ "$SOURCE_GITREV" == "latest-tag" ]]; then
			# my solution gets the latest tag, using git tag aware versioning.
			# to to use the latest git tag, based on commit dates, you can use this instead:
			# git describe --tags $(git rev-list --tags --max-count=1)
			SOURCE_GITREV=$(git -C "$SOURCE_DEST" tag --sort=v:refname | tail -n 1)
			sourcerer_info "latest tag is: $SOURCE_GITREV"
		fi

		requested_commit=$(git -C "$SOURCE_DEST" rev-parse "$SOURCE_GITREV^{commit}")
		HEAD=$(git -C "$SOURCE_DEST" rev-parse "HEAD^{commit}")
		if [[ "$requested_commit" == "$HEAD" ]]; then
			export SOURCE_STATE="gitrev equals"
		else
			export SOURCE_STATE="gitrev differs"
		fi
	else
		export SOURCE_STATE="source n/a"
	fi
}

function clean_source() {
	# NOTE: has to be called after check_source_state
	# in order for SOURCE_DEST to be set

	(
		cd "$SOURCE_DEST"
		# moving staged modifcations to unstaged
		git reset .
		git submodule foreach --recursive git reset .

		# removing unstaged modification
		git checkout .
		git submodule foreach --recursive git checkout .

		# removing build and other cache files
		# -d recurse into directories
		# -x remove all untracked files (ignoring gitignore rules)
		git clean -fdx
		git submodule foreach --recursive git clean -fdx
	)
}

function init_source() {
	giturl=$1

	if [[ "${SOURCE_STATE:-"unset"}" == "unset" ]]; then
		sourcerer_error "incorrect use of init_source. call check_source_state before initilasing."
		exit 1
	fi

	if [[ "$SOURCE_STATE" != "source n/a" ]]; then
		sourcerer_error "source already exists. cannot initialize."
		exit 1
	fi

	sourcerer_info "[$SOURCE_NAME] initialising..."
	git clone "$giturl" "$SOURCE_DEST"
	(
		cd "$SOURCE_DEST"
		git checkout --detach "$SOURCE_GITREV"
		git submodule update --init --recursive
	)
}

function update_source() {
	if [[ "${SOURCE_STATE:-"unset"}" == "unset" ]]; then
		sourcerer_error "incorrect use of update_source. call check_source_state before updating."
		exit 1
	fi

	if [[ "$SOURCE_STATE" == "source n/a" ]]; then
		sourcerer_error "source does not exist. cannot update."
		exit 1
	elif [[ "$SOURCE_STATE" == "gitrev equals" ]]; then
		sourcerer_error "source is already at requested gitrev. no reason to update."
		exit 1
	fi

	(
		cd "$SOURCE_DEST"
		git checkout --detach "$SOURCE_GITREV"
		git submodule update --init --recursive
	)
}

# calling code has to declare two functions, called
# <sourcename>_installed
# <sourcename>_build_and_install
# pass in the url as arg
function source_git() {
	SOURCE_STATE=${SOURCE_STATE:?call check_source_state before run}

	giturl=${1:?git url is required}
	is_installed="${SOURCE_NAME}_installed"
	build_and_install="${SOURCE_NAME}_build_and_install"

	if ! declare -F "$build_and_install" >/dev/null; then
		echo "Error: Function '$build_and_install' does not exist." >&2
		exit 1
	fi
	if ! declare -F "$is_installed" >/dev/null; then
		echo "Error: Function '$is_installed' does not exist." >&2
		exit 1
	fi

	if [[ "$SOURCE_STATE" == "source n/a" ]]; then
		init_source "$giturl"
		sourcerer_info "[$SOURCE_NAME] installing..."
		(cd "$SOURCE_DEST" && "$build_and_install")
	elif [[ "$SOURCE_STATE" == "gitrev equals" ]]; then
		if $is_installed; then
			sourcerer_info "$SOURCE_NAME already installed. Skipping."
		else
			# edge case. means its already cloned, but build probably failed
			clean_source
			sourcerer_info "[$SOURCE_NAME] installing..."
			(cd "$SOURCE_DEST" && "$build_and_install")
		fi
	elif [[ "$SOURCE_STATE" == "gitrev differs" ]]; then
		clean_source
		update_source "$giturl"
		sourcerer_info "[$SOURCE_NAME] updating..."
		(cd "$SOURCE_DEST" && "$build_and_install")
	fi
}
