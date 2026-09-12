# sourcerer

This has been created by me, within [ribynlinux - my dotfiles repository](https://github.com/RobinMeow/ribynlinux)
I was re-inventing the wheel over and over to build several apps from source,
while providing upgrading/downgrading mechanisms across multiple machines using
my dotfiles repository.
Overtime this reuseable script came to be.

You can use it to build apps, which are not packaged in your distro's
package manager. Examples:

- [neovim](https://github.com/neovim/neovim),
- [hyprland](https://github.com/pythops/bluetui)
- [bluetui](https://github.com/pythops/bluetui),
- and any other git repository

Provides a stable experience and optionally bleeding edge.

### Who this is not for

If you just want to build from source once, this is not for your.
This is a script to be used for automation purposes. e.g. dotfile repository
which build neovim from source and updates it, or rolls back as needed.

### Requirements

Basic programming skills will be helpful, since I dont have the time to make a
guide, for how to make a dotfiles repository with shell scripts and git.
There are guide for this online, so I consider it be out of scope for this script.
It's still possible to integrate it for those without this knowledge, using vibe
coding or learn the fundamentals on what is needed.

---

depends on `git` to be in your `PATH`.  
You most likely have this installed already.

if not, install git

```sh
# for fedora
sudo dnf install git
# for arch
sudo pacman -S git
# all distros have git. just google the command if you don't know it.
```

## Getting Started

### How to use or install

Its just a file. It is up 2 you, to decide what which way
solves your problem the best.  
You can use it as a git submodule, fetch the latest version at runtime using `curl`
or `wget`.  
I personally just copy the file contents and put it it my git repo.  
Can't bother with git submodules. I do this for two repositories currently.


The script is very small you could just read through it.
You should not execute random scripts from the internet anyways.
Regardless, here some examples on how to use it.

### Example: Neovim

[build nvim from source on fedora in 14 lines of code](./examples/build-nvim-from-source-on-fedora.sh)
[build nvim from source on fedora in 14 lines of code - with comments](./examples/build-nvim-from-source-on-fedora-with-comments.sh)
> Important: updates never happen automatically, nothing is running in the background.
You have to invoke `build-nvim-from-source-fedora.sh` to update. And only then,
it will check for available updates. Which makes it suitable to put it into your
dotfiles repository.

[nvim from source build without sourcerer](./examples/build-nvim-from-without-sourcerer.sh)  
This one is a past version of my dotfiles repo,
which was not reuseable for other git repos.  
Shows _(and explains in the comments)_ some problems which sourcerer solves.

[Example of my dotfiles repo, which uses this](https://github.com/RobinMeow/ribynlinux/tree/master/lib/nvim)
> This is a bit more complex, becuase my dotfiles support arch and fedora.
Also I can toggle my configuration between from-source-build and packaged bin installation.

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
