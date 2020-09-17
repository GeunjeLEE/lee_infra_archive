rpm -qa | grep wget > /dev/null
if [ $? -ne 0 ]; then
    yum install wget -y
fi

wget https://github.com/prometheus/node_exporter/releases/download/v0.18.1/node_exporter-0.18.1.linux-amd64.tar.gz -P /tmp/
tar -xvzf /tmp/node_exporter-0.18.1.linux-amd64.tar.gz -C /tmp/
useradd -rs /bin/false nodeusr
mv /tmp/node_exporter-0.18.1.linux-amd64/node_exporter /usr/local/bin/
touch /etc/systemd/system/node_exporter.service

cat << 'EOF' >> /etc/systemd/system/node_exporter.service
[Unit]
Description=Node Exporter
After=network.target
[Service]
User=nodeusr
Group=nodeusr
Type=simple
ExecStart=/usr/local/bin/node_exporter
[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl start node_exporter
systemctl enable node_exporter