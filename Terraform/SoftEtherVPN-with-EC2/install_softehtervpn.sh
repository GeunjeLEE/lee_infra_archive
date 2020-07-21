#!/bin/bash
sudo timedatectl set-timezone Asia/Tokyo
sudo yum -y update
sudo yum -y install git gcc ncurses-devel readline-devel openssl-devel zlib-devel

wget -P /tmp/ https://github.com/SoftEtherVPN/SoftEtherVPN_Stable/releases/download/v4.32-9731-beta/softether-src-v4.32-9731-beta.tar.gz
tar xvzf /tmp/softether-src-v4.32-9731-beta.tar.gz -C /tmp
cd /tmp/v4.32-9731
./configure
sudo make
sudo make install

touch /tmp/vpnserver.service

cat << EOF > /tmp/vpnserver.service
[Unit]
Description=Softether VPN Server Service
After=network.target

[Service]
Type=forking
User=root
ExecStart=/usr/bin/vpnserver start
ExecStop=/usr/bin/vpnserver stop
Restart=on-abort
WorkingDirectory=/opt/vpnserver/
ExecStartPre=/sbin/ip link set dev eth0 promisc on

[Install]
EOF

sudo chmod 755 /tmp/vpnserver.service
sudo chown root:root /tmp/vpnserver.service
sudo mv /tmp/vpnserver.service /etc/systemd/system/vpnserver.service

sudo mv /tmp/v4.32-9731 /opt/vpnserver
sudo systemctl daemon-reload
sudo systemctl start vpnserver
sudo systemctl enable vpnserver

sudo rm -rf /tmp/softether-src-v4.32-9731-beta.tar.gz