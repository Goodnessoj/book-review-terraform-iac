#!/usr/bin/env bash

# Exit immediately on error, treat unset variables as errors, and fail on pipe errors.
set -euo pipefail

# ==============================
# Required variables
# ==============================
# Public ALB DNS where users access the frontend/backend entrypoint.
PUBLIC_ALB_DNS="public-alb-dns"
# Internal ALB DNS used by Nginx to route /api requests to backend.
INTERNAL_ALB_DNS="internal-alb-dns"

# Local paths used during deployment.
APP_DIR="$HOME/book-review-app"
FRONTEND_DIR="$APP_DIR/frontend"
NGINX_CONF="/etc/nginx/sites-available/book-review"

echo "========================================"
echo "Updating system..."
echo "========================================"
sudo apt update && sudo apt upgrade -y

echo "========================================"
echo "Installing Node.js, Nginx, and Git..."
echo "========================================"
# Install Node.js LTS plus web server/tools required for frontend hosting.
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt install -y nodejs nginx git

echo "========================================"
echo "Cloning or updating frontend repo..."
echo "========================================"
# Clone repository on first run, otherwise pull latest changes.
if [ -d "$APP_DIR" ]; then
  echo "Repo already exists. Pulling latest changes..."
  cd "$APP_DIR"
  git pull
else
  git clone https://github.com/pravinmishraaws/book-review-app.git "$APP_DIR"
fi

cd "$FRONTEND_DIR"

echo "========================================"
echo "Installing frontend dependencies..."
echo "========================================"
# Install frontend Node dependencies.
sudo npm install

echo "========================================"
echo "Creating .env.local..."
echo "========================================"
# Configure Next.js frontend API base URL.
cat > .env.local <<EOF
NEXT_PUBLIC_API_URL=http://${PUBLIC_ALB_DNS}
EOF

echo "========================================"
echo "Building frontend..."
echo "========================================"
# Create production build assets.
npm run build

echo "========================================"
echo "Installing PM2..."
echo "========================================"
# Use PM2 to run Next.js and keep process alive across failures/reboots.
sudo npm install -g pm2

echo "========================================"
echo "Restarting frontend with PM2..."
echo "========================================"
# Recreate process to pick up latest build and config.
pm2 delete frontend || true
pm2 start npm --name "frontend" -- start
pm2 save

echo "========================================"
echo "Configuring PM2 startup..."
echo "========================================"
# Register PM2 with systemd so app starts after instance reboot.
pm2 startup systemd -u ubuntu --hp /home/ubuntu || true

echo "========================================"
echo "Creating Nginx config..."
echo "========================================"
# Nginx serves as reverse proxy:
# - /api/* -> internal ALB backend
# - /*     -> local Next.js app on port 3000
sudo tee "$NGINX_CONF" > /dev/null <<EOF
server {
    listen 80;
    server_name _;

    # API calls -> internal ALB -> app server
    location /api/ {
        proxy_pass http://${INTERNAL_ALB_DNS}:3001/api/;
        proxy_http_version 1.1;
        proxy_set_header Host              \$host;
        proxy_set_header X-Real-IP         \$remote_addr;
        proxy_set_header X-Forwarded-For   \$proxy_add_x_forwarded_for;
        proxy_set_header Origin            http://${PUBLIC_ALB_DNS};
        proxy_connect_timeout 60s;
        proxy_send_timeout    60s;
        proxy_read_timeout    60s;
    }

    # Everything else -> Next.js on port 3000
    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade           \$http_upgrade;
        proxy_set_header Connection        'upgrade';
        proxy_set_header Host              \$host;
        proxy_cache_bypass                 \$http_upgrade;
        proxy_set_header X-Real-IP         \$remote_addr;
        proxy_set_header X-Forwarded-For   \$proxy_add_x_forwarded_for;
        proxy_connect_timeout 60s;
        proxy_send_timeout    60s;
        proxy_read_timeout    60s;
    }
}
EOF

echo "========================================"
echo "Enabling Nginx site..."
echo "========================================"
# Enable this site and disable default server block.
sudo ln -sf /etc/nginx/sites-available/book-review /etc/nginx/sites-enabled/book-review
sudo rm -f /etc/nginx/sites-enabled/default

echo "========================================"
echo "Testing Nginx config..."
echo "========================================"
# Validate configuration before reload.
sudo nginx -t

echo "========================================"
echo "Reloading Nginx..."
echo "========================================"
# Apply updated Nginx configuration without full restart.
sudo systemctl reload nginx

echo "========================================"
echo "Deployment complete"
echo "========================================"
pm2 status
sudo systemctl status nginx --no-pager