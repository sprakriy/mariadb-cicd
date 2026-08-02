#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Ensure the script is run with sudo or as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run this script with sudo."
  exit 1
fi

echo "Starting MariaDB configuration..."

# Execute MariaDB commands as root
mariadb -u root <<EOF
-- Show existing databases
SHOW DATABASES;

-- Create the new database
CREATE DATABASE IF NOT EXISTS liquibase_db;

-- Create the user and set the password
CREATE USER IF NOT EXISTS 'test1'@'localhost' IDENTIFIED BY 'test1';

-- Grant privileges on the specific database
GRANT ALL PRIVILEGES ON liquibase_db.* TO 'test1'@'localhost';

-- Reload privileges to apply changes
FLUSH PRIVILEGES;

EOF

echo "MariaDB configuration completed successfully!"

