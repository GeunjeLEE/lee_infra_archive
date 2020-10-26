#!/bin/bash

sudo rpm --import https://repo.saltstack.com/py3/redhat/8/x86_64/archive/2019.2.5/SALTSTACK-GPG-KEY.pub -y

sudo touch /etc/yum.repos.d/saltstack.repo
sudo cat << 'EOF' >> /etc/yum.repos.d/saltstack.repo
[saltstack-repo]
name=SaltStack repo for RHEL/CentOS $releasever PY3
baseurl=https://repo.saltstack.com/py3/redhat/$releasever/$basearch/archive/2019.2.5
enabled=1
gpgcheck=1
gpgkey=https://repo.saltstack.com/py3/redhat/$releasever/$basearch/archive/2019.2.5/SALTSTACK-GPG-KEY.pub
EOF

sudo yum install salt-master -y

sudo systemctl start salt-master
sudo systemctl enable salt-master