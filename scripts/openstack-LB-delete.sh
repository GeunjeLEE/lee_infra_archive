#set the lb id
LB_ID=$1

# delete the lb and all sub components.
LB_DATA=$(neutron lbaas-loadbalancer-show ${LB_ID})
echo $LB_DATA
LB_LISTENERS_ID=$(echo -e "$LB_DATA" | awk -F'"' '/listeners/ {print $4}')
echo $LB_LISTENERS_ID
LB_POOL_ID=$(neutron lbaas-listener-show $LB_LISTENERS_ID | grep default_pool_id | awk '{print $4}')
echo $LB_POOL_ID
LB_HE_CH_ID=$(neutron lbaas-pool-show $LB_POOL_ID | grep healthmonitor | awk '{print $4}')
echo ${LB_HE_CH_ID}

echo "------------------------"

neutron lbaas-healthmonitor-delete "${LB_HE_CH_ID}"
neutron lbaas-pool-delete "${LB_POOL_ID}"
neutron lbaas-listener-delete "${LB_LISTENERS_ID}"
neutron lbaas-loadbalancer-delete "${LB_ID}"