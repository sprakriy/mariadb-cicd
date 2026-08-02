#!/usr/bin/env bash
LOGFILE="$HOME/mariadb-install-$(date +%Y%m%d-%H%M%S).log"

exec > >(tee -a "$LOGFILE") 2>&1

echo "Log file: $LOGFILE"

set -euo pipefail

echo "=== MariaDB clean installation starting ==="

echo
echo "=== Checking for running MySQL/MariaDB processes ==="

if pgrep -af "mysqld|mariadbd"; then
    echo
    echo "ERROR: Existing database process detected."
    echo "Stop it before installing."
    exit 1
fi


echo
echo "=== Removing stale MariaDB repository configuration ==="

sudo rm -f /etc/apt/sources.list.d/mariadb.list
sudo rm -f /etc/apt/keyrings/mariadb.gpg


echo
echo "=== Repairing package manager ==="

sudo dpkg --configure -a || true
sudo apt --fix-broken install -y


echo
echo "=== Updating Ubuntu repositories ==="

sudo apt clean
sudo apt update


echo
echo "=== Installing MariaDB from Ubuntu repository ==="

sudo apt install -y \
    mariadb-server \
    mariadb-client


echo
echo "=== Enabling MariaDB service ==="

sudo systemctl enable mariadb
sudo systemctl restart mariadb


echo
echo "=== Testing MariaDB ==="

sudo systemctl --no-pager status mariadb

echo

sudo mariadb -e "SELECT VERSION();"


echo
echo "=== Installation complete ==="
echo
echo "Optional hardening:"
echo "sudo mariadb-secure-installation"
