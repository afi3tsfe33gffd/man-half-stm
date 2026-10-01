#!/bin/bash

set -e

echo "Starting X-UI + StormDNS + Nginx..."

export NGINX_PORT=3000

# -----------------------------
# Configure 3x-ui
# -----------------------------

cd /usr/local/x-ui

echo "Applying 3x-ui settings..."

./x-ui setting -port 2053 -webBasePath /managepanel/ || true

# -----------------------------
# Generate Nginx configuration
# -----------------------------

echo "Generating nginx.conf from template..."

envsubst '${NGINX_PORT}' \
    < /etc/nginx/nginx.conf.template \
    > /etc/nginx/nginx.conf

# -----------------------------
# Start StormDNS Client
# -----------------------------

echo "Starting StormDNS Client..."

cd /opt/stormdns

./StormDNS_Client_Linux_AMD64 \
    --config /opt/stormdns/client_config.toml &

STORMDNS_PID=$!

echo "StormDNS PID: $STORMDNS_PID"

# Give StormDNS some time to start

sleep 2

# -----------------------------
# Start 3x-ui
# -----------------------------

echo "Starting 3x-ui..."

cd /usr/local/x-ui

./x-ui &

XUI_PID=$!

echo "X-UI PID: $XUI_PID"

sleep 2

# -----------------------------
# Start Nginx
# -----------------------------

echo "Starting Nginx..."

nginx -t

exec nginx -g "daemon off;"
