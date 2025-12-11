# semyon's dotfiles

hey there! welcome to my personal configuration files. this is where i keep my linux setup tidy, organized, and ready to roll.

## what's inside

*   **shell** - bash with custom aliases, functions, and history handling
*   **terminal** - configurations for wezterm & ghostty
*   **editor** - neovim setup using lazy.nvim
*   **system tools** - git, tmux, htop, btop, neofetch
*   **prompt** - starship

## getting started

### automatic setup (recommended)
```bash
git clone https://github.com/semyonfox/dotfiles.git ~/dotfiles
cd ~/dotfiles
./setup.sh
```

the setup script will:
- detect your OS (arch, ubuntu, fedora, macos, etc.)
- install stow using the right package manager
- backup any existing dotfiles that would conflict (including .config items)
- deploy all configs with stow
- verify everything is working
- rollback automatically if anything fails

**dry-run mode:**
```bash
./setup.sh --dry-run  # or -n
```
test the installation without making any changes

### quick manual install
```bash
git clone https://github.com/semyonfox/dotfiles.git ~/dotfiles && cd ~/dotfiles && stow home
```
make sure stow is installed first!

### detailed setup

setting this up on a new machine is super easy:

1.  **install stow**
    ```bash
    # arch/endeavouros
    sudo pacman -S stow

    # ubuntu/debian
    sudo apt install stow

    # fedora
    sudo dnf install stow

    # macos
    brew install stow
    ```

2.  **clone the repo**
    ```bash
    git clone https://github.com/semyonfox/dotfiles.git ~/dotfiles
    cd ~/dotfiles
    ```

3.  **deploy with stow**
    ```bash
    stow home
    ```

    that's it! stow will symlink everything from the `home/` package to your `$HOME` directory.

4.  **verify installation** (optional)
    ```bash
    # check if symlinks were created
    ls -la ~ | grep "dotfiles"

    # test bashrc loads without errors
    bash -c "source ~/.bashrc && echo 'success'"
    ```

### what gets installed

stow will create symlinks for:
- shell configs: `.bashrc`, `.bash_aliases`, `.bash_functions`, `.bash_profile`, `.profile`
- terminal: `.wezterm.lua`
- git: `.gitconfig`
- tmux: `.tmux.conf`
- apps: `.config/btop`, `.config/ghostty`, `.config/htop`, `.config/kitty`, `.config/neofetch`, `.config/starship.toml`

## structure and usage

this repo uses [GNU Stow](https://www.gnu.org/software/stow/) for symlink management:

*   **home/** - package containing all dotfiles (`.bashrc`, `.config/nvim`, etc.)
*   when you run `stow home`, it creates symlinks in `~` that point to files in `home/`
*   **example**: `home/.bashrc` → `~/.bashrc`

## managing dotfiles

**add new configs**: place them in `home/` (or `home/.config/` for XDG configs), then run `stow home`

**update existing**: just edit files in the repo, changes are instant (they're symlinked!)

**remove symlinks**: `stow -D home` (deletes all symlinks created by stow)

**re-stow**: if symlinks get broken, run `stow -R home` to recreate them

## troubleshooting

**conflict errors when stowing?**
```bash
# backup existing configs first
mkdir -p ~/backup
mv ~/.bashrc ~/.gitconfig ~/.tmux.conf ~/backup/

# then try stowing again
stow home
```

**check if symlinks are working:**
```bash
# verify all symlinks are valid
for file in .bashrc .gitconfig .tmux.conf .wezterm.lua; do
  if [ -L ~/"$file" ]; then
    echo "$file: symlinked to $(readlink ~/$file)"
  else
    echo "$file: not a symlink"
  fi
done
```

**restore original configs:**
```bash
cd ~/dotfiles
stow -D home  # remove all symlinks
cp ~/backup/* ~/  # restore from backup
```

## license

mit - feel free to fork this, steal code, or learn from my messy experiments.

## acknowledgements

big thanks to these folks for some great inspiration:
*   [omerxx](https://github.com/omerxx/dotfiles) for dotfiles inspiration
*   [axenide](https://github.com/starship/starship/discussions/1107#discussioncomment-13953875) for starship config ideas
