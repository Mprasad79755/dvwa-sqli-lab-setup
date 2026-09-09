#!/bin/bash

set -e

DVWA_DIR="/var/www/html/DVWA"
DVWA_URL="http://localhost/DVWA"

DB_NAME="dvwa"
DB_USER="dvwa"
DB_PASSWORD="p@ssw0rd"

echo "======================================================"
echo "        DVWA SQL INJECTION LAB SETUP"
echo "======================================================"

# ------------------------------------------------------
# Check sudo/root
# ------------------------------------------------------

if [ "$EUID" -ne 0 ]; then
    echo
    echo "ERROR: Please run this script with sudo."
    echo
    echo "Use:"
    echo "sudo ./setup-dvwa.sh"
    exit 1
fi

# ------------------------------------------------------
# Step 1 - Update Kali
# ------------------------------------------------------

echo
echo "[1/10] Updating package lists..."

apt update

# ------------------------------------------------------
# Step 2 - Install required software
# ------------------------------------------------------

echo
echo "[2/10] Installing required software..."

apt install -y \
    apache2 \
    mariadb-server \
    php \
    php-mysql \
    libapache2-mod-php \
    git \
    curl \
    firefox-esr

echo
echo "Required software installed successfully."

# ------------------------------------------------------
# Step 3 - Start Apache
# ------------------------------------------------------

echo
echo "[3/10] Starting Apache..."

systemctl enable apache2
systemctl restart apache2

if systemctl is-active --quiet apache2; then
    echo "Apache: RUNNING"
else
    echo "ERROR: Apache failed to start."
    systemctl status apache2 --no-pager
    exit 1
fi

# ------------------------------------------------------
# Step 4 - Start MariaDB
# ------------------------------------------------------

echo
echo "[4/10] Starting MariaDB..."

systemctl enable mariadb
systemctl restart mariadb

if systemctl is-active --quiet mariadb; then
    echo "MariaDB: RUNNING"
else
    echo "ERROR: MariaDB failed to start."
    systemctl status mariadb --no-pager
    exit 1
fi

# ------------------------------------------------------
# Step 5 - Clone DVWA
# ------------------------------------------------------

echo
echo "[5/10] Downloading DVWA..."

mkdir -p /var/www/html

if [ -d "$DVWA_DIR/.git" ]; then

    echo "DVWA already exists."
    echo "Updating DVWA..."

    git -C "$DVWA_DIR" pull --ff-only

elif [ -d "$DVWA_DIR" ]; then

    echo "DVWA directory already exists."
    echo "Using existing directory."

else

    git clone https://github.com/digininja/DVWA.git "$DVWA_DIR"

fi

echo
echo "DVWA location:"
echo "$DVWA_DIR"

# ------------------------------------------------------
# Step 6 - Configure DVWA
# ------------------------------------------------------

echo
echo "[6/10] Configuring DVWA..."

cd "$DVWA_DIR/config"

if [ ! -f config.inc.php ]; then
    cp config.inc.php.dist config.inc.php
fi

# Database server
sed -i "s/^\s*\$_DVWA\['db_server'\].*/\$_DVWA['db_server'] = '127.0.0.1';/" config.inc.php

# Database name
sed -i "s/^\s*\$_DVWA\['db_database'\].*/\$_DVWA['db_database'] = 'dvwa';/" config.inc.php

# Database user
sed -i "s/^\s*\$_DVWA\['db_user'\].*/\$_DVWA['db_user'] = 'dvwa';/" config.inc.php

# Database password
sed -i "s/^\s*\$_DVWA\['db_password'\].*/\$_DVWA['db_password'] = 'p@ssw0rd';/" config.inc.php

echo "DVWA database configuration completed."

# ------------------------------------------------------
# Step 7 - Create database and user
# ------------------------------------------------------

echo
echo "[7/10] Creating MariaDB database..."

mariadb <<SQL

CREATE DATABASE IF NOT EXISTS dvwa;

CREATE USER IF NOT EXISTS 'dvwa'@'localhost'
IDENTIFIED BY 'p@ssw0rd';

ALTER USER 'dvwa'@'localhost'
IDENTIFIED BY 'p@ssw0rd';

GRANT ALL PRIVILEGES ON dvwa.*
TO 'dvwa'@'localhost';

FLUSH PRIVILEGES;

SQL

echo
echo "Database created:"
echo "Database : dvwa"
echo "User     : dvwa"

# ------------------------------------------------------
# Step 8 - Set permissions
# ------------------------------------------------------

echo
echo "[8/10] Setting DVWA permissions..."

mkdir -p "$DVWA_DIR/hackable/uploads"

chmod -R 777 "$DVWA_DIR/hackable/uploads"
chmod -R 777 "$DVWA_DIR/config"

chown -R www-data:www-data "$DVWA_DIR"

chmod -R 777 "$DVWA_DIR/config"
chmod -R 777 "$DVWA_DIR/hackable/uploads"

echo "Permissions configured."

# ------------------------------------------------------
# Step 9 - Restart Apache
# ------------------------------------------------------

echo
echo "[9/10] Restarting Apache..."

systemctl restart apache2

if systemctl is-active --quiet apache2; then
    echo "Apache: RUNNING"
else
    echo "ERROR: Apache failed after restart."
    exit 1
fi

# ------------------------------------------------------
# Step 10 - Test DVWA
# ------------------------------------------------------

echo
echo "[10/10] Testing DVWA..."

HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$DVWA_URL")

echo "HTTP Status: $HTTP_STATUS"

if [ "$HTTP_STATUS" = "200" ] || [ "$HTTP_STATUS" = "302" ]; then
    echo "DVWA web server: OK"
else
    echo "WARNING: DVWA returned HTTP status $HTTP_STATUS"
fi

# ------------------------------------------------------
# Finish
# ------------------------------------------------------

echo
echo "======================================================"
echo "              DVWA SETUP COMPLETE"
echo "======================================================"

echo
echo "Open DVWA:"
echo
echo "http://localhost/DVWA"

echo
echo "DVWA Login:"
echo "Username: admin"
echo "Password: password"

echo
echo "Database:"
echo "Database: dvwa"
echo "User:     dvwa"
echo "Password: p@ssw0rd"

echo
echo "======================================================"
echo "        NOW PERFORM THE LAB MANUALLY"
echo "======================================================"

echo
echo "1. Open Firefox."
echo "2. Visit:"
echo "   http://localhost/DVWA"

echo
echo "3. Click:"
echo "   Create / Reset Database"

echo
echo "4. Login:"
echo "   admin / password"

echo
echo "5. Go to:"
echo "   DVWA Security"

echo
echo "6. Select:"
echo "   Low"

echo
echo "7. Click Submit."

echo
echo "8. Open:"
echo "   SQL Injection"

echo
echo "9. Perform your SQL Injection experiment manually."

echo
echo "======================================================"

# ------------------------------------------------------
# Open Firefox
# ------------------------------------------------------

sleep 2

if command -v firefox-esr >/dev/null 2>&1; then

    firefox-esr "$DVWA_URL" >/dev/null 2>&1 &

elif command -v firefox >/dev/null 2>&1; then

    firefox "$DVWA_URL" >/dev/null 2>&1 &

else

    echo
    echo "Firefox was not found."
    echo "Open manually:"
    echo "$DVWA_URL"

fi

echo
echo "Firefox opened."
echo