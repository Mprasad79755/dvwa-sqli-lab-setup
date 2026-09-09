#!/bin/bash

set -e

DVWA_SOURCE="$1"
WEB_DIR="/var/www/html/DVWA"

DB_NAME="dvwa"
DB_USER="dvwa"
DB_PASSWORD="p@ssw0rd"

echo "======================================================"
echo " DVWA LAB - STEP 2: CONFIGURE LOCAL DVWA"
echo "======================================================"

if [ "$EUID" -ne 0 ]; then
    echo
    echo "ERROR: Run this script with sudo."
    echo
    echo "Usage:"
    echo "sudo ./02-configure-local-dvwa.sh /path/to/DVWA"
    exit 1
fi

if [ -z "$DVWA_SOURCE" ]; then
    echo
    echo "ERROR: DVWA folder path is required."
    echo
    echo "Example:"
    echo "sudo ./02-configure-local-dvwa.sh /home/kali/Downloads/DVWA"
    exit 1
fi

# Expand ~ if used in the path
DVWA_SOURCE="${DVWA_SOURCE/#\~/$HOME}"

if [ ! -d "$DVWA_SOURCE" ]; then
    echo
    echo "ERROR: DVWA folder not found:"
    echo "$DVWA_SOURCE"
    echo
    echo "Check the path and try again."
    exit 1
fi

if [ ! -f "$DVWA_SOURCE/index.php" ]; then
    echo
    echo "ERROR: The selected folder does not appear to be DVWA."
    echo
    echo "index.php was not found in:"
    echo "$DVWA_SOURCE"
    exit 1
fi

echo
echo "[1/8] Preparing Apache web directory..."

mkdir -p /var/www/html

if [ -d "$WEB_DIR" ]; then
    echo "Existing DVWA installation found."
    echo "Removing old installation..."
    rm -rf "$WEB_DIR"
fi

echo
echo "[2/8] Copying manually downloaded DVWA..."

cp -a "$DVWA_SOURCE" "$WEB_DIR"

echo
echo "DVWA copied to:"
echo "$WEB_DIR"

echo
echo "[3/8] Creating DVWA configuration..."

cd "$WEB_DIR/config"

if [ ! -f config.inc.php ]; then
    cp config.inc.php.dist config.inc.php
fi

echo
echo "Configuring database settings..."

sed -i "s/^\s*\$_DVWA\['db_server'\].*/\$_DVWA['db_server'] = '127.0.0.1';/" config.inc.php

sed -i "s/^\s*\$_DVWA\['db_database'\].*/\$_DVWA['db_database'] = 'dvwa';/" config.inc.php

sed -i "s/^\s*\$_DVWA\['db_user'\].*/\$_DVWA['db_user'] = 'dvwa';/" config.inc.php

sed -i "s/^\s*\$_DVWA\['db_password'\].*/\$_DVWA['db_password'] = 'p@ssw0rd';/" config.inc.php

echo
echo "Database configuration completed."

echo
echo "[4/8] Creating MariaDB database..."

systemctl start mariadb

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
echo "Database created successfully."

echo
echo "Database : dvwa"
echo "User     : dvwa"
echo "Password : p@ssw0rd"

echo
echo "[5/8] Setting DVWA permissions..."

mkdir -p "$WEB_DIR/hackable/uploads"

chmod -R 777 "$WEB_DIR/hackable/uploads"

chmod -R 777 "$WEB_DIR/config"

chown -R www-data:www-data "$WEB_DIR"

chmod -R 777 "$WEB_DIR/config"

chmod -R 777 "$WEB_DIR/hackable/uploads"

echo
echo "Permissions configured."

echo
echo "[6/8] Restarting Apache..."

systemctl restart apache2

if systemctl is-active --quiet apache2; then
    echo "Apache: RUNNING"
else
    echo
    echo "ERROR: Apache is not running."
    systemctl status apache2 --no-pager
    exit 1
fi

echo
echo "[7/8] Testing DVWA..."

HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost/DVWA/)

echo
echo "HTTP Status: $HTTP_STATUS"

if [ "$HTTP_STATUS" = "200" ] || [ "$HTTP_STATUS" = "302" ]; then
    echo "DVWA web server: OK"
else
    echo "WARNING: DVWA returned HTTP status $HTTP_STATUS"
fi

echo
echo "[8/8] Setup completed."

echo
echo "======================================================"
echo " DVWA LOCAL SETUP COMPLETE"
echo "======================================================"

echo
echo "Open Firefox and visit:"
echo
echo "http://localhost/DVWA"

echo
echo "DVWA Login:"
echo "Username: admin"
echo "Password: password"

echo
echo "Database:"
echo "Server:   127.0.0.1"
echo "Database: dvwa"
echo "User:     dvwa"
echo "Password: p@ssw0rd"

echo
echo "======================================================"
echo " CONTINUE THE EXPERIMENT MANUALLY"
echo "======================================================"

echo
echo "1. Open http://localhost/DVWA"

echo
echo "2. Click:"
echo "   Create / Reset Database"

echo
echo "3. Login:"
echo "   admin / password"

echo
echo "4. Open:"
echo "   DVWA Security"

echo
echo "5. Select:"
echo "   Low"

echo
echo "6. Click Submit"

echo
echo "7. Open:"
echo "   SQL Injection"

echo
echo "8. Perform the experiment manually."

echo
echo "======================================================"