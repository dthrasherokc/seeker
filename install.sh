#!/usr/bin/env bash

LOG_DIR=$PWD/logs
DB_DIR=$PWD/db
ILOG=$LOG_DIR/install.log

mkdir -p $LOG_DIR $DB_DIR

status_check() {
    if [ $? -eq 0 ]; then
        echo "$1 - Installed" >> "$ILOG"
    else
        echo "$1 - Failed!" >> "$ILOG"
    fi
    echo '--------------------' >> "$ILOG"
}

install_packages() {
    echo -e '=====================\nINSTALLING PACKAGES\n=====================\n' > "$ILOG"
    local cmd=$1 shift
    local packages=$@

    for pkg in $packages; do
        echo -ne "$pkg\r" &>> "$ILOG"
        $cmd $pkg -y &>> "$ILOG"
        status_check $pkg
    done
}

echo -e '[!] Installing Dependencies...\n'

# Detect distribution and call install_packages with the appropriate command and package names
if [ -f '/etc/arch-release' ]; then
    install_packages "sudo pacman -S --needed --noconfirm" python3 python-pip python-requests python-packaging python-psutil php
elif [ -f '/etc/fedora-release' ]; then
    install_packages "sudo dnf install" python3 python3-pip python3-requests python3-packaging python3-psutil php
elif [ -z "${TERMUX_VERSION}" ]; then
    install_packages "sudo apt install" python3 python3-pip python3-requests python3-packaging python3-psutil php
else
    # Special handling for Termux which doesn't have sudo and uses different package names
    pkgs="python php"
    pip_pkgs="requests packaging psutil"
    for pkg in $pkgs; do
        install_packages "apt install" $pkg
    done
    for pkg in $pip_pkgs; do
        install_packages "pip install -U" $pkg
    done
fi

echo -e 'COMPLETED\n' >> "$ILOG"
echo -e '\n[+] Log Saved :' "$ILOG"
