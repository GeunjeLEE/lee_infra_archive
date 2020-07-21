#!/bin/bash

export OS_AUTH_URL=
export OS_PROJECT_NAME=admin
export OS_TENANT_NAME=admin
export OS_USERNAME=admin
export OS_PASSWORD=
export OS_IMAGE_API_VERSION=1
export OS_VOLUME_API_VERSION=2
#export OS_PROJECT_DOMAIN_ID=default
#export OS_USER_DOMAIN_ID=default
export OS_REGION_NAME=RegionTwo

. /root/openstack-clients/bin/activate

function error_exit {
    echo "$@" 1>&2
    exit 1
}

DATE_6HS=`date -d '6 hour ago' "+%Y%m%d%H%M"`
DATE_24HS=`date -d '24 hour ago' "+%Y%m%d%H%M"`
DATE_1WS=`date -d '1 week ago' "+%Y%m%d%H%M"`

DATE_E=`date "+%Y%m%d%H%M"`

SERVER_LIST=("A" "B")

n=${#SERVER_LIST[@]}
n=$((n - 1))

echo "<html>"
while [ $n -ge 0 ];
do
    HOST="${SERVER_LIST[$n]}"
    WAI=`grep $HOST traffic_check_host.list | cut -d "," -f 2`
    echo "Host : $HOST <br>" 
    echo "<img src=\"imagsrc"><br>"
    echo "====================<br>"
    n=$((n - 1))
done
echo "</html>"