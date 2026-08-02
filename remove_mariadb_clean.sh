#!/usr/bin/env bash
LOGFILE="$HOME/mariadb-install-$(date +%Y%m%d-%H%M%S).log"

exec > >(tee -a "$LOGFILE") 2>&1

echo "Log file: $LOGFILE"

set -euo pipefail

echo "=== MariaDB/MySQL cleanup starting ==="

echo
echo "=== Stopping MicroStack (if present) ==="
if snap list 2>/dev/null | grep -q "^microstack"; then
    sudo snap stop microstack || true
fi

echo
echo "=== Stopping database services ==="
sudo systemctl stop mariadb 2>/dev/null || true
sudo systemctl stop mysql 2>/dev/null || true

echo
echo "=== Killing leftover database processes ==="
sudo pkill -f mariadbd || true
sudo pkill -f mysqld || true

echo
echo "=== Removing MariaDB/MySQL packages ==="
sudo apt purge -y \
    mariadb-server \
    mariadb-client \
    mariadb-common \
    mariadb-server-core* \
    mariadb-client-core* \
    mysql-server \
    mysql-client \
    mysql-common || true

echo
echo "=== Removing MariaDB repository entries ==="
sudo rm -f /etc/apt/sources.list.d/mariadb.list

echo
echo "=== Removing MariaDB repository keys ==="
sudo rm -f /etc/apt/keyrings/mariadb.gpg

echo
echo "=== Cleaning package state ==="
sudo dpkg --configure -a || true
sudo apt --fix-broken install -y
sudo apt autoremove -y
sudo apt autoclean

echo
read -p "Delete ALL database data (/var/lib/mysql)? (yes/no): " answer

if [[ "$answer" == "yes" ]]; then
    sudo rm -rf /var/lib/mysql
    sudo rm -rf /etc/mysql
    echo "Database files deleted."
else
    echo "Database files preserved."
fi

echo
echo "=== Final apt refresh ==="
sudo apt update

echo
echo "Cleanup complete."
