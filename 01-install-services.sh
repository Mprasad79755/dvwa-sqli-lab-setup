#!/bin/bash

set -e

echo "======================================================"
echo " DVWA LAB - STEP 1: INSTALL SERVICES"
echo "======================================================"

if [ "$EUID" -ne 0 ]; then
    echo
    echo "ERROR: Run this script with sudo."
    echo
    echo "Usage:"
    echo "sudo ./01-install-services.sh"
    exit 1
fi

echo
echo "[1/5] Updating Kali package lists..."

apt update

echo
echo "[2/5] Installing Apache, MariaDB, PHP and Git..."

apt install -y \
    apache2 \
    mariadb-server \
    php \
    php-mysql \
    libapache2-mod-php \
    git \
    curl

echo
echo "Required software installed successfully."

echo
echo "[3/5] Starting Apache..."

systemctl enable apache2
systemctl start apache2

if systemctl is-active --quiet apache2; then
    echo "Apache: RUNNING"
else
    echo "ERROR: Apache failed to start."
    systemctl status apache2 --no-pager
    exit 1
fi

echo
echo "[4/5] Starting MariaDB..."

systemctl enable mariadb
systemctl start mariadb

if systemctl is-active --quiet mariadb; then
    echo "MariaDB: RUNNING"
else
    echo "ERROR: MariaDB failed to start."
    systemctl status mariadb --no-pager
    exit 1
fi

echo
echo "[5/5] Checking installed software..."

echo
echo "Apache:"
apache2 -v | head -n 1

echo
echo "MariaDB:"
mariadb --version

echo
echo "PHP:"
php -v | head -n 1

echo
echo "Git:"
git --version

echo
echo "======================================================"
echo " STEP 1 COMPLETE"
echo "======================================================"

echo
echo "Apache status:"
systemctl is-active apache2

echo
echo "MariaDB status:"
systemctl is-active mariadb

echo
echo "======================================================"
echo " IMPORTANT"
echo "======================================================"

echo
echo "DVWA was NOT downloaded automatically."
echo
echo "Download or clone DVWA manually."
echo
echo "Official DVWA repository:"
echo "https://github.com/digininja/DVWA"

echo
echo "After you have the DVWA folder, run:"
echo
echo "sudo ./02-configure-local-dvwa.sh /path/to/DVWA"

echo
echo "Example:"
echo "sudo ./02-configure-local-dvwa.sh /home/kali/Downloads/DVWA"

echo
echo "======================================================"