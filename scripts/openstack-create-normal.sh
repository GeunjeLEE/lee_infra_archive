prefix=MExxxB

# ネットワーク作成
network_name=${prefix}_network
openstack network create $network_name

# サブネット作成
subnet_name=${prefix}_subnet
openstack subnet create $subnet_name \
    --network $network_name \
    --subnet-range 10.80.80.0/24

# ルーター作成
router_name=${prefix}_router
openstack router create $router_name
openstack router set $router_name --external-gateway "Public network for Toast JP"
openstack router add subnet $router_name $subnet_name

# セキュリティグループ作成
sg_name=${prefix}_security-group
openstack security group create $sg_name
openstack security group rule create $sg_name --protocol tcp --dst-port 22:22 --remote-ip 0.0.0.0/0
openstack security group rule create $sg_name --protocol tcp --dst-port 80:80 --remote-ip 0.0.0.0/0
openstack security group rule create $sg_name --protocol icmp

# インスタンス作成
server1_name=${prefix}_server-1
server2_name=${prefix}_server-2

function create_fip_if_not_exists () {
    # フローティングIP作成
    fip=$(
        openstack floating ip create "Public network for Toast JP" \
            | awk '/ floating_ip_address /{ print $4; }'
    )

    echo $fip
}

function create_instance () {
    local instance_name=$1
    openstack server create \
        --image "Ubuntu-18.04-64bit" \
        --flavor CGF-1_1_50 \
        --key-name befor_test_key \
        --security-group $sg_name \
        --property vnc_keymap="ja" \
        --property set_password="specified" \
        --property password="Aasdf!1234" \
        --network $network_name \
        $instance_name

    openstack server add floating ip $instance_name $(create_fip_if_not_exists)
}

function create_instance_not_fip () {
    local instance_name=$1
    openstack server create \
        --image "Ubuntu-18.04-64bit" \
        --flavor CGF-1_1_50 \
        --security-group $sg_name \
        --key-name befor_test_key \
        --property vnc_keymap="ja" \
        --property set_password="specified" \
        --property password="Aasdf!1234" \
        --network $network_name \
        $instance_name
}

create_instance $server1_name
sleep 5
create_instance_not_fip $server2_name

# ロードバランサー作成
lb_name=${prefix}_loadbalancer
neutron lbaas-loadbalancer-create --name $lb_name $subnet_name

## ロードバランサーのポート`vip_port_id`にセキュリティグループを設定
lb_vip_port_id=$(
    neutron lbaas-loadbalancer-show $lb_name \
        | awk '/ vip_port_id /{ print $4; }'
)
openstack port set $lb_vip_port_id --security-group $sg_name

## リスナー追加
lb_listener_name=${prefix}_loadbalancer-listener-http
neutron lbaas-listener-create \
    --name $lb_listener_name \
    --loadbalancer $lb_name \
    --protocol HTTP \
    --protocol-port 80

## プール追加
lb_pool_name=${prefix}_loadbalancer-pool
neutron lbaas-pool-create \
    --name $lb_pool_name \
    --lb-algorithm ROUND_ROBIN \
    --listener $lb_listener_name \
    --protocol HTTP

## メンバー追加
function add_member () {
    local server_name=$1
    local fixed_ip=$(
        openstack port list --server $server_name \
            | awk -F \' '/ ip_address=/{ print $2; }'
    )
    neutron lbaas-member-create \
        --subnet "$subnet_name" \
        --address $fixed_ip \
        --protocol-port 80 \
        $lb_pool_name
}


add_member $server1_name
add_member $server2_name
## ヘルスモニター設定
neutron lbaas-healthmonitor-create \
    --delay 5 \
    --max-retries 2 \
    --timeout 10 \
    --type HTTP \
    --health-check-port 80 \
    --pool $lb_pool_name


## ロードバランサーにフローティングIPを割り当てる
openstack floating ip set $(create_fip_if_not_exists) --port $lb_vip_port_id