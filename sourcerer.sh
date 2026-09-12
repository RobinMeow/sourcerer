#!/usr/bin/env bash
set -euo pipefail

mkdir -p "$HOME/.local/share/ribyn"
SOURCE="$HOME/.local/share/ribyn"

# WARN: source-manager.sh expect the SOURCE_NAME to be equal to the SOURCE_DEST
# I think it would still work when not. but would be more clean
# also expects the name to match the pkg-config value if used.

function check_source_state() {
	export SOURCE_NAME=${1:?1st arg SOURCE_NAME is required}
	export SOURCE_GITREV=${2:?2nd arg SOURCE_GITREV is required}
	export SOURCE_DEST="$SOURCE/$SOURCE_NAME"

	if [[ -d "$SOURCE_DEST" ]]; then
		# quick and dirty, fetch everything, so we dont have to bother with origin/checks
		# do not ues --jobs=10. which will cause gh rate limits to block my requests.
		# then it will prompt for a login to fetch/clone anything..
		# even tho, I did not exceed the rate limit
		git -C "$SOURCE_DEST" fetch --all --tags --prune

		if [[ "$SOURCE_GITREV" == "latest-tag" ]]; then
			# apparently my solution gets the latest tag, using git tag aware versioning.
			# to to use the latest git tag, based on commit dates, you can use this:
			# git describe --tags $(git rev-list --tags --max-count=1)
			SOURCE_GITREV=$(git -C "$SOURCE_DEST" tag --sort=v:refname | tail -n 1)
			info "latest tag is: $SOURCE_GITREV"
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

	# -d recurse into directories
	# -x remove all untracked files (ignoring gitignore rules)

	(
		cd "$SOURCE_DEST"
		# moving staged modifcations to unstaged
		git reset .
		git submodule foreach --recursive git reset .

		# removing unstaged modification
		git checkout .
		git submodule foreach --recursive git checkout .

		# removing build and other cache files
		git clean -fdx
		git submodule foreach --recursive git clean -fdx
	)
}

function init_source() {
	giturl=$1

	if [[ "${SOURCE_STATE:-"unset"}" == "unset" ]]; then
		source "$RIBYN_ROOT/core/utils.sh"
		error "incorrect use of init_source. call check_source_state before initilasing."
		exit 1
	fi

	if [[ "$SOURCE_STATE" != "source n/a" ]]; then
		source "$RIBYN_ROOT/core/utils.sh"
		error "source already exists. cannot initialize."
		exit 1
	fi

	info "[$SOURCE_NAME] initialising..."
	git clone "$giturl" "$SOURCE_DEST"
	(
		cd "$SOURCE_DEST"
		git checkout --detach "$SOURCE_GITREV"
		git submodule update --init --recursive
	)
}

function update_source() {
	if [[ "${SOURCE_STATE:-"unset"}" == "unset" ]]; then
		source "$RIBYN_ROOT/core/utils.sh"
		error "incorrect use of update_source. call check_source_state before updating."
		exit 1
	fi

	if [[ "$SOURCE_STATE" == "source n/a" ]]; then
		source "$RIBYN_ROOT/core/utils.sh"
		error "source does not exist. cannot update."
		exit 1
	elif [[ "$SOURCE_STATE" == "gitrev equals" ]]; then
		source "$RIBYN_ROOT/core/utils.sh"
		error "source is already at requested gitrev. no reason to update."
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
		info "[$SOURCE_NAME] installing..."
		(cd "$SOURCE_DEST" && "$build_and_install")
	elif [[ "$SOURCE_STATE" == "gitrev equals" ]]; then
		if $is_installed; then
			info "$SOURCE_NAME already installed. Skipping."
		else
			# edge case. means its already cloned, but build probably failed
			clean_source
			info "[$SOURCE_NAME] installing..."
			(cd "$SOURCE_DEST" && "$build_and_install")
		fi
	elif [[ "$SOURCE_STATE" == "gitrev differs" ]]; then
		clean_source
		update_source "$giturl"
		info "[$SOURCE_NAME] updating..."
		(cd "$SOURCE_DEST" && "$build_and_install")
	fi
}
