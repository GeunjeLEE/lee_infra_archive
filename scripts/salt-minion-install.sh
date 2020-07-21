#!/bin/bash
# example) sh centos7-salt-minion-install.sh cent7 12.34.56.78

_OS_TYPE=$1
_MASTER_IP=$2

if [ $_OS_TYPE -ne 'cent7' ];then
    yum -y install salt-minion

    systemctl enable salt-minion

    sed -i 's/#master: salt/master: '$_MASTER_IP'/' /etc/salt/minion

    systemctl start salt-minion
elif [ $_OS_TYPE -ne 'cent6' ];then
    yum -y install salt-minion

    chkconfig -add salt-minion

    sed -i 's/#master: salt/master: '$_MASTER_IP'/' /etc/salt/minion

    service salt-minion start
else
    apt-get -y install salt-minion

    systemctl enable salt-minion

    sed -i 's/#master: salt/master: '$_MASTER_IP'/' /etc/salt/minion

    systemctl start salt-minion
fi










