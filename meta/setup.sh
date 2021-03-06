#!/bin/bash

####
# Dotfiles setup
####

set -e

DOTFILES_DIR="$HOME/.dotfiles"
TMP_DIR="$HOME/.tmp"


# Function to link folders with backup if it already exists
function link-with-backup () {
    local src="$1"
    local dst="$2"

    if [[ -e "$dst" ]]; then
        # Backup and move it
        local ts=$(date +%Y-%m-%d.%H:%M:%S)
        local backup="$dst.bak-${ts}"

        echo -e "\e[41mBacking\e[0m up existing file '$dst' to '$backup'"
        mv "$dst" "$backup"
    fi

    echo -e "\e[1mLinking:\e[0m '$src' --> '$dst'"
    ln -s "$src" "$dst"
}

# Setup bash configurations
function _bash () {
    link-with-backup "$DOTFILES_DIR/bash/bash_profile" "$HOME/.bash_profile"
    link-with-backup "$DOTFILES_DIR/bash/bashrc" "$HOME/.bashrc"
    touch $DOTFILES_DIR/bash/bashrc.local
    link-with-backup "$DOTFILES_DIR/bash/bashrc" "$HOME/.bashrc.local"
}

# Setup vim configurations
function _vim () {
    link-with-backup "$DOTFILES_DIR/vim/vimrc" "$HOME/.vimrc"
}

# Setup git configurations
function _git () {
    link-with-backup "$DOTFILES_DIR/git/gitconfig" "$HOME/.gitconfig"

    # Setup git bash completion
    pushd $DOTFILES_DIR/git
    curl https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash -o git-completion.bash
    echo "\n#For git bash completion" >> $HOME/.bashrc.local
    echo "source $DOTFILES_DIR/git/git-completion.bash" >> $HOME/.bashrc.local
    popd
}

# Setup usr tmp dir
function _tmp () {
    mkdir -p $TMP_DIR
}


####
# RUN
####

# Print Usage
if [ -z "$*" ]; then
    echo "$0 - Error
    Usage:
        ./install.sh default
        ./install.sh [MODULE...]

    The "default" option installs:
        - bash
        - vim
        - git
        - .tmp

    Modules:
        - bash: links .bashrc, .bash_profile, aliases
        - vim: links .vimrc
        - git: links .gitconfig
        - .tmp: ~/.tmp directory for user tmp files
    "
    exit 1
fi

# Run default
if [ $1="default" ]; then
    _bash
    _tmp
    _vim
    _git
    exit 1
fi

# Run modules
for module in "$@"; do
    $module
done
