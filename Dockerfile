FROM alpine:3.19

RUN apk add --no-cache \
    curl \
    bash \
    ca-certificates \
    socat \
    tzdata \
    sqlite \
    nginx \
    gettext \
    && ln -sf /usr/share/zoneinfo/Asia/Tehran /etc/localtime

# دانلود و نصب 3x-ui
RUN curl -L https://github.com/mhsanaei/3x-ui/releases/download/v3.8.5/x-ui-linux-amd64.tar.gz -o /tmp/x-ui.tar.gz \
    && tar -xzf /tmp/x-ui.tar.gz -C /usr/local/ \
    && rm /tmp/x-ui.tar.gz \
    && chmod +x /usr/local/x-ui/x-ui

# ایجاد مسیرها
RUN mkdir -p \
    /etc/x-ui \
    /var/log/x-ui \
    /usr/local/stormdns \
    /usr/local/sni-spoof \
    /opt/config

# StormDNS
COPY stormdns/StormDNS_Client_Linux_AMD64 /usr/local/stormdns/
COPY stormdns/client_config.toml /usr/local/stormdns/

RUN chmod +x /usr/local/stormdns/StormDNS_Client_Linux_AMD64

# SNI Spoof
COPY sni-spoof/sni-spoof-rs /usr/local/sni-spoof/

RUN chmod +x /usr/local/sni-spoof/sni-spoof-rs

# Nginx و Startup
COPY nginx.conf.template /etc/nginx/nginx.conf.template
COPY start.sh /start.sh

RUN chmod +x /start.sh

CMD ["/start.sh"]
