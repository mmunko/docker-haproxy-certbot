# haproxy1.6.9 with certbot
FROM ubuntu:18.04

RUN apt-get update && apt-get install -y software-properties-common libssl1.0.0 libpcre3 --no-install-recommends && rm -rf /var/lib/apt/lists/*

# Setup HAProxy
RUN add-apt-repository ppa:vbernat/haproxy-1.9
RUN apt update &&\
apt-get install -y haproxy=1.9.\*

# Install Supervisor, cron, libnl-utils, net-tools, iptables
RUN apt-get update && apt-get install -y supervisor cron libnl-utils net-tools iptables && \
  apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Setup Supervisor
RUN mkdir -p /var/log/supervisor
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Install Certbot
RUN add-apt-repository universe && add-apt-repository ppa:certbot/certbot
RUN apt-get update && apt-get install -y certbot


# Setup Certbot
RUN mkdir -p /usr/local/etc/haproxy/certs.d
RUN mkdir -p /usr/local/etc/letsencrypt
COPY certbot.cron /etc/cron.d/certbot
COPY cli.ini /usr/local/etc/letsencrypt/cli.ini
COPY haproxy-refresh.sh /usr/bin/haproxy-refresh
COPY haproxy-restart.sh /usr/bin/haproxy-restart
COPY certbot-certonly.sh /usr/bin/certbot-certonly
COPY certbot-renew.sh /usr/bin/certbot-renew
RUN chmod +x /usr/bin/haproxy-refresh /usr/bin/haproxy-restart /usr/bin/certbot-certonly /usr/bin/certbot-renew

# Add startup script
COPY start.sh /start.sh
RUN chmod +x /start.sh

# Start
CMD ["/start.sh"]
