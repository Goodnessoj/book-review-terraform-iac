#!/usr/bin/env bash

# Exit immediately on error, treat unset variables as errors, and fail on pipe errors.
set -euo pipefail

# ==============================
# Required variables
# ==============================
# RDS endpoint (hostname only, no protocol).
DB_HOST="rds-endpoint.amazonaws.com"
# Database password for DB_USER.
DB_PASS="rds-password"
# Public ALB DNS used for backend CORS allow-list (hostname only).
ALLOWED_ORIGINS="your-public-alb-dns"

echo "========================================"
echo "Updating system..."
echo "========================================"
sudo apt update && sudo apt upgrade -y

echo "========================================"
echo "Installing Node.js and dependencies..."
echo "========================================"
# Install Node.js LTS and required system packages for backend runtime.
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt install -y nodejs mysql-client nginx git

echo "========================================"
echo "Cloning project..."
echo "========================================"
# Clone repository on first run, otherwise pull latest changes.
if [ -d "$HOME/book-review-app" ]; then
  echo "Repo already exists, pulling latest changes..."
  cd "$HOME/book-review-app"
  git pull
else
  git clone https://github.com/pravinmishraaws/book-review-app.git "$HOME/book-review-app"
fi

cd "$HOME/book-review-app/backend"

echo "========================================"
echo "Installing backend dependencies..."
echo "========================================"
# Install backend Node dependencies.
sudo npm install

echo "========================================"
echo "Creating .env file..."
echo "========================================"
# Generate backend environment configuration.
cat > .env <<EOF
# Database
DB_HOST=${DB_HOST}
# Database username expected by your RDS instance.
DB_USER=admin
DB_PASS=${DB_PASS}
DB_NAME=book_review_db
DB_DIALECT=mysql

#App port
PORT=3001


# Auth
# Replace with a strong secret for production.
JWT_SECRET=mysecret

# CORS
ALLOWED_ORIGINS=http://${ALLOWED_ORIGINS}
EOF

echo "========================================"
echo "Installing PM2..."
echo "========================================"
# Use PM2 to keep backend process alive and restart on reboot.
sudo npm install -g pm2

echo "========================================"
echo "Restarting backend with PM2..."
echo "========================================"
# Recreate process to pick up latest code/config.
pm2 delete bk-backend || true
pm2 start src/server.js --name "bk-backend"
pm2 save

echo "========================================"
echo "Setting up PM2 startup..."
echo "========================================"
# Register PM2 with systemd so app starts after instance reboot.
pm2 startup systemd -u ubuntu --hp /home/ubuntu

echo "========================================"
echo "Deployment complete"
echo "========================================"
pm2 status