#!/bin/sh

log() {
    echo "[AMZ] $1"
}

error() {
    echo "[ERR] $1"
}

prompt() {
    echo -n "[AMZ] $2: "
    read $1 < /dev/tty
}

download_repo() {
    [ -n "$(ls -A $INSTALL_DIR 2>/dev/null)" ] && {
        error "destination path '$INSTALL_DIR' already exists and is not an empty directory."
        return 1
    }

    out=$(git clone --branch $BRANCH $REMOTE $1 2>&1)
    ret=$?

    echo $out | sed 's/^/[GIT] /'

    return $ret
}

install() {
    mv -n "$1/ayy-my-zsh" "$2"
}

cleanup_repo() {
    rm -rf $1
}

REMOTE="https://github.com/nitroo/ayy-my-zsh.git"
BRANCH="master"
INSTALL_DIR=~/.ayy-my-zsh

log "Looks like you're ready to install Ayy My ZSH!"

prompt INPUT_DIR "Where would you like to install ayy-my-zsh files? (Press Enter for $INSTALL_DIR)"
[ -n "$INPUT_DIR" ] && INSTALL_DIR="$INPUT_DIR"

AFTER_INSTALL=$(echo "source $INSTALL_DIR/ayy-my-zsh.zsh")

TEMP_DIR=$(mktemp -d)
download_repo "$TEMP_DIR" || {
    cat << END
[ERR]
[ERR] Install failed. Something went wrong when downloading the repository.

    Please try again or proceed with a manual installation.
END
    exit 1
}

log "installing ayy-my-zsh into $INSTALL_DIR..."
install $TEMP_DIR $INSTALL_DIR || {
    error "failed to move files from '$TEMP_DIR' to '$INSTALL_DIR'"
    error "temp files will remain on exit."
    exit
}

log "cleaning up temporary files."
cleanup_repo $TEMP_DIR

log "Install successful. Now just add the following to your .zshrc file:\n\t$AFTER_INSTALL"
