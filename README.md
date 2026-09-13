# sourcerer

automate build from source programs, apps, protocols with upgrade,
downgrade, bleeding edge latest with auto-update functionalities,
with less boilerplate code, while maintaining a consistent code base.
It's your DIY yoghurt, like yay, paru, trizen, etc.. but it does not
hide the implementation details. Making you aware of what's
actually happening under the hood.

This has been created by me, within [ribynlinux - my dotfiles repository](https://github.com/RobinMeow/ribynlinux)
I was re-inventing the wheel over and over to build several apps from source,
while providing upgrading/downgrading mechanisms across multiple machines using
my dotfiles repository.
Over time this reuseable script came to be.

You can use it to build apps, which are not packaged in your distro's
package manager. Examples:

- [neovim](https://github.com/neovim/neovim),
- [hyprland](https://github.com/hyprwm/hyprland)
- [bluetui](https://github.com/pythops/bluetui),
- and any other git repository

Provides a stable experience and optionally bleeding edge.

**Who this is not for:**
If you just want to build from source once, this is not for you.
Think of this as a tool, to help you write a script, to automate the installation
for multiple machines, distros, reproductions, or getting auto-update functionality
for a program which you want to build from source.

## Requirements

Basic programming skills will be helpful, since I don't have the time to make a
guide, for how to make a dotfiles repository with shell scripts and git.
There are guide for this online, so I consider it to be out of scope for this script.
It's still possible to integrate it for those without this knowledge, using vibe
coding or learn the fundamentals on what is needed.

Depends on `git` to be in your `PATH`.  
You most likely have this installed already.

**If not, install git:**

```sh
# for fedora
sudo dnf install git
# for arch
sudo pacman -S git
# all distros have git. just google the command if you don't know it.
```

## Getting Started

### How to use or install

It is only one file. It is up to you, to decide which way
solves your problem the best.  
You can use it as a git submodule, fetch the latest version at runtime using `curl`
or `wget`.  
In my [dotfiles repo](https://github.com/RobinMeow/ribynlinux)
I manage a copy, and in [hyribyn](https://github.com/RobinMeow/hyribyn)
I use git submodules.

The script is very small you could just read through it.
You should not execute random scripts from the internet anyways.
Regardless, here are some examples on how to use it.

**How to write your own installation shell script (using neovim+fedora as example):**

```sh
#!/usr/bin/env bash
set -euo pipefail

# install the dependencies you need to build and install the app.
# neovim mentions this here: https://github.com/neovim/neovim/blob/stable/BUILD.md#build-prerequisites
# which is linked in their README.md
sudo dnf -y install ninja-build cmake gcc make gettext curl glibc-gconv-extra git

# Optionally, before sourcing sourcerer.sh
# this is the directory, all git repositories will be cloned
# into and built. I recommended to use your dotfiles repo
# name, or your linux username. My username is ribyn
# if not provided, sourcerer will fallback to $HOME/.local/share/sourcerer
# means neovim will be git cloned to $HOME/.local/share/sourcerer/neovim
export SOURCERER_DEST="$HOME/.local/share/ribyn"
# source the sourcerer.sh file from this repo
# to make its functions available in this script
source "$HOME/mydotfiles/path-to/sourcerer.sh"

# define a function named <appname>_build_and_install
# this will be called by sourcerer.
function neovim_build_and_install() {
  # this contains the build and install instructions these are usually code
  # snippets mentioned in the README.md of the app you wish to install
  make CMAKE_BUILD_TYPE=RelWithDebInfo
  sudo make install
}

# define a function named <appname>_installed
# this will be called by sourcerer.
function neovim_installed() {
  # return an exit code, for whether or not the app is already installed
  command -v nvim >/dev/null 2>&1
  # some git repositories don't install a program which provides a command.
  # for example hyprpolkitagent which is required for permissions in hyprland
  # could check like this
  # [[ -x "/usr/libexec/hyprpolkitagent" ]]
  # or hyprland protocols which is required to build hyprland:
  # pkg-config --exists $SOURCE_NAME
  # more examples available in hyribyn: https://github.com/RobinMeow/hyribyn
}
# the first argument "neovim" is <appname> for the functions above
# the second argument is the git revision. This can be a remote branch
# e.g. origin/master or a git tag (v0.12.5 is a git tag here) or a commit hash
# It is recommended to not hardcode it, but use environment variables
# exported in your .zshenv (or .zshrc or .bashrc) and read them here
# which makes it easy, to upgrade/downgrade by changing its value,
# and re-run this script. instead of changing this script itself.
check_source_state "neovim" "v0.12.5"
source_git "https://github.com/neovim/neovim"
```

now the first time you run this script, it will git clone neovim,
build and install it.
if you re-run it, it will log "already installed", unless you
change the git revision, to upgrade or downgrade.
you can also remove the git repo from your filesystem, to force
a rebuild on the same git revision.

next up a real-world examples for neovim:

### real world small scale examples for neovim

[build nvim from source on fedora in 14 lines of code](./examples/build-nvim-from-source-on-fedora.sh)
[build nvim from source on fedora in 14 lines of code - with comments](./examples/build-nvim-from-source-on-fedora-with-comments.sh)
> Important: updates never happen automatically, nothing is running in the background.
You have to invoke the script to update. And only then, it will check for available
updates. Which makes it suitable to put it into your dotfiles repository.

[bad example without sourcerer - nvim from source build](./examples/build-nvim-from-without-sourcerer.sh)  
This one is a past version of my dotfiles repo,
which was not reuseable for other git repos.  
Shows _(and explains in the comments)_ some problems which sourcerer solves.

[Example of my dotfiles repo, which uses this](https://github.com/RobinMeow/ribynlinux/tree/master/lib/nvim)
> This is a bit more complex, because my dotfiles support arch and fedora.
Also I can toggle my configuration between from-source-build and packaged bin installation.

### real world large scale example: hyribyn - hyprland from source for any distro

[hyribyn](https://github.com/RobinMeow/hyribyn) uses the `sourcerer` to
build the whole hyprland stack from source as well as commonly used programs like
hyprlock and hyprshutdown.
Which makes a total of 19 git repositories to build from source.

## Contributing

- strict no AI/LLM
- only submit a pull request after having a prior issue or discussion
- keep PRs small and focused

- [ ] make cloning submodules optional
  (only relevant, if the git repo has submodules, which you do not want to have)

## Philosophy

Idempotency. This is supposed to be used for dotfile repos.
And maybe does many changes per day, and frequently re-runs
install and syncing scripts. So it should support that, without
re-installing, re-cloning, etc. on each run.
this is an extremely small script. This is the kind of git repository
which will have its "last commit date" 3 years back, and still works.
it does one thing, and does it well.

## Limitation

- if source name `<appname>` contains spaces, you can't use source_git and
  have to use the alternative way of calling the other functions.
  I think zsh allows this, but I don't want to depend on zsh.
  most repos use dashes so `hyprland-protocols_build_and_install` works just fine
