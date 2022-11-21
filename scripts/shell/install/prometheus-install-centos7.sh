rpm -qa | grep wget > /dev/null
if [ $? -ne 0 ]; then
    yum install wget -y
fi

wget https://github.com/prometheus/prometheus/releases/download/v2.14.0/prometheus-2.14.0.linux-amd64.tar.gz -P /tmp/
useradd --no-create-home --shell /bin/false prometheus
mkdir /etc/prometheus
mkdir /var/lib/prometheus
chown prometheus:prometheus /etc/prometheus
chown prometheus:prometheus /var/lib/prometheus
tar -xvzf /tmp/prometheus-2.14.0.linux-amd64.tar.gz -C /tmp/
mv /tmp/prometheus-2.14.0.linux-amd64 /tmp/prometheuspackage
cp /tmp/prometheuspackage/prometheus /usr/local/bin/
cp /tmp/prometheuspackage/promtool /usr/local/bin/
chown prometheus:prometheus /usr/local/bin/prometheus
chown prometheus:prometheus /usr/local/bin/promtool
cp -r /tmp/prometheuspackage/consoles /etc/prometheus
cp -r /tmp/prometheuspackage/console_libraries /etc/prometheus
chown -R prometheus:prometheus /etc/prometheus/consoles
chown -R prometheus:prometheus /etc/prometheus/console_libraries
touch /etc/prometheus/prometheus.yml

cat << 'EOF' >> /etc/prometheus/prometheus.yml
global:
  scrape_interval: 10s
scrape_configs:
  - job_name: 'prometheus_master'
    scrape_interval: 5s
    static_configs:
      - targets: ['localhost:9090']
EOF

chown prometheus:prometheus /etc/prometheus/prometheus.yml
touch /etc/systemd/system/prometheus.service

cat << 'EOF' >> /etc/systemd/system/prometheus.service
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target
[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus --config.file /etc/prometheus/prometheus.yml --storage.tsdb.path /var/lib/prometheus/ --web.console.templates=/etc/prometheus/consoles --web.console.libraries=/etc/prometheus/console_libraries
[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl start prometheus
systemctl enable prometheus