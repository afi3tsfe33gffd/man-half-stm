#!/bin/bash

set -e

echo "Starting X-UI + StormDNS + SNI Spoof + Nginx..."

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
# Start StormDNS
# -----------------------------

if [ "${ENABLE_STORMDNS:-false}" = "true" ]; then

    echo "Starting StormDNS Client..."

    cd /usr/local/stormdns

    ./StormDNS_Client_Linux_AMD64 \
        --config /usr/local/stormdns/client_config.toml \
        --resolvers /opt/config/client_resolvers.txt &

    STORMDNS_PID=$!

    echo "StormDNS PID: $STORMDNS_PID"

    sleep 2

else

    echo "StormDNS disabled."

fi

# -----------------------------
# Start SNI Spoof
# -----------------------------

echo "Starting SNI Spoof..."

cd /usr/local/sni-spoof

./sni-spoof-rs /opt/config/config.json &

SNI_SPOOF_PID=$!

echo "SNI Spoof PID: $SNI_SPOOF_PID"

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
