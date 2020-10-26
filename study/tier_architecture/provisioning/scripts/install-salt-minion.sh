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

sudo yum install salt-minion -y

sudo sed -i 's/#master: salt/master: '$1'/' /etc/salt/minion

sudo touch /etc/salt/grains
sudo cat << 'EOF' >> /etc/salt/grains
roles:
  - role_1
EOF

sudo sed -i 's/role_1/'$2'/' /etc/salt/grains

sudo systemctl start salt-minion
sudo systemctl enable salt-minion