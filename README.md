# sourcerer

This has been created by me, within [ribynlinux - my dotfiles repository](https://github.com/RobinMeow/ribynlinux)
I was re-inventing the wheel over and over to build several apps from source,
while providing updating/downgrading mechanisms.
Overtime this reuseable script came to be.

You can use it to build apps, which arent packages in your distros
package manager. Examples:

- [neovim](https://github.com/neovim/neovim),
- [hyprland](https://github.com/pythops/bluetui)
- [bluetui](https://github.com/pythops/bluetui),
- and any other git repository

Provides a stable experience and optionally bleeding edge.

## Installation

Its just a file. It is up 2 you, to decide what which way
solves your problem the best.
You can use it as a git submodule, fetch the latest version at runtime using `curl`
or `wget`.
Honestly possibilities are alot.
I personally just copy the file contents and put it it my git repo.
Can't bother with git submodules. I do this for two repositories currently.

## Dependencies

depends on `git` to be in your `PATH`.  
You most likely have this installed already.

if not, install git
```sh
# substitute `dnf` with the package manager which comes bundled in your distro
sudo dnf install git
```

## Getting Started

the script is very small you could just read through it.

### Example: Neovim

`build-nvim-from-source-fedora.sh`
```sh
#!/bin/bash
set -euo pipefail

source "path/to/sourcerer.sh"

# NOTE: use this before building,
# if I have issue and git clean -fdx is not enough
# sudo make clean distclean

# i copied this from my own dotfiles repo
# could be, not all of these are neovim dependencies
# but deps of a plugin I use. e.g. lazy-nvim
sudo dnf --assumeyes install \
  ninja-build \
  cmake \
  gcc \
  make \
  unzip \
  gettext \
  curl

function neovim_build_and_install() {
  make CMAKE_BUILD_TYPE="RelWithDebInfo"
  sudo make install
}
function neovim_installed() {
  command -v nvim >/dev/null 2>&1
}
source "$RIBYN_ROOT/core/source-manager.sh"
# will only ever upgrade/downgrade if you change this value.
# or you can override this in your .zshrc/.bashrc.
# Example: if you want to stay on bleeding edge development:
# export NVIM_GITREF="origin/master"
# Example: update to latest stable
# export NVIM_GITREF="origin/stable"
NVIM_GITREF=${NVIM_GITREF:-"v0.12.5"}
check_source_state "neovim" "$NVIM_GITREF"
source_git "https://github.com/neovim/neovim"
```

> Important: updates never happen automatically, nothing is running in the background.
You have to invoke `build-nvim-from-source-fedora.sh` to update. And only then,
it will check for available updates. Which makes it suitable to put it into your
dotfiles repository.

Just for comparison, what sourcerer solves. [Here is an old version of my neovim
from source build](./examples/build-neovim-from-source-arch.sh), which was not reuseable for other git repos.

### Example: hyribyn - hyprland from source for any distro

hyribyn uses this to build hyprland, and optional apps like,
`hyprshutdown`, `hyprlock`, etc.. from source.
[hyribyn](https://github.com/RobinMeow/hyribyn)

## Contributing

- strict no AI/LLM
- only submit a pull request after having a prior issue or discussion
- keep PRs small and focused

## philosophy

Idemptency. This is supposed to be used for dotfile repos.
And maybe does many changes per day, and frequently re-runs
install and syncing scripts. So it should support that, without
re-installing, re-cloning, etc. on each run.
this is an extremely small script. This is the kind of git repository
which will have it "last commit date" 3 years back, and still works.
it does one thing, and does it well.
