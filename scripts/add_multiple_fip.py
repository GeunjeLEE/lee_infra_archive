from keystoneauth1.identity import v2
from keystoneauth1 import session

from novaclient import client as nova_client
from neutronclient.v2_0 import client as neutron_client
import requests, json

def get_session():
    print "get session...\n"

    OS_AUTH_URL = "keystone_endpoint"
    OS_USERNAME = "username"
    OS_PASSWORD = "passwd"
    OS_TENANT_NAME = "admin"

    auth = v2.Password(
        auth_url=OS_AUTH_URL,
        username=OS_USERNAME,
        password=OS_PASSWORD,
        tenant_name=OS_TENANT_NAME
    )
    return session.Session(auth=auth)

def get_server_info(sess, _server_uuid):
    nova = nova_client.Client(2, region_name='RegionTwo', session=sess)
    instance = nova.servers.get(_server_uuid)

    return instance

def subnet_filter(subnet_dic, cidr):

    result = []
    for i in range(len(cidr)):
        if cidr[i] in subnet_dic.keys():
            result.append(subnet_dic[cidr[i]])

    return result

def get_subents(sess,project_info):
    neutron = neutron_client.Client(region_name='RegionTwo', session=sess)
    subnets = neutron.list_subnets(tenant_id=project_info)

    subents_info = {}
    for i in range(len(subnets['subnets'])):
        if "Default Network" not in subnets['subnets'][i]['name']:
            subents_info[subnets['subnets'][i]['cidr']] = subnets['subnets'][i]['id']

    return subents_info

def get_security_group_id(sess, project_info, sg_name):
    neutron = neutron_client.Client(region_name='RegionTwo', session=sess)
    security_groups = neutron.list_security_groups(tenant_id=project_info, name=sg_name)

    if security_groups['security_groups']:
        return security_groups['security_groups'][0]['id']
    else:
        return None

def port_filter(subnet_id, port_id):
    result = []
    for i in range(len(subnet_id)):
        for j in range(len(port_id)):
            if subnet_id[i] == port_id[j]['subnet_id']:
                result.append(port_id[j]['id'])

    return result

def get_port_id(sess, server_id):
    token = sess.get_token()

    headers = {
        'Content-Type': 'application/json',
        'X-Auth-Token': token
    }

    URL = 'http://nova_api_url/servers/{}/vpc-interfaces'.format(server_id)
    response_info = requests.get(URL, headers=headers).text
    dump_response = json.loads(response_info)

    ids = []
    for i in range(len((dump_response['vpcinterfaces']))):
         ids.append(dump_response['vpcinterfaces'][i])

    return ids

def add_port_through_Toast_api_and_return_port_id(sess, subnet_id, server_id, security_group_id):
    print "add port to instance({}) in subnets({})".format(server_id, subnet_id)

    token = sess.get_token()

    responses = []
    for i in range(len(subnet_id)):
        headers = {
            'Content-Type': 'application/json',
            'X-Auth-Token': token
        }

        data = {
            "vpcinterface": {
                "security_groups": [
                    security_group_id
                ],
                "subnet_id": subnet_id[i]
            }
        }

        URL = 'http://nova_api_ur/servers/{}/vpc-interfaces'.format(server_id)
        responses.append(requests.post(URL,headers=headers,data=json.dumps(data)))

    return responses

def associate_fip_to_port(sess, fip_id, port_id):
    neutron = neutron_client.Client(region_name='RegionTwo', session=sess)

    data = {
        "floatingip": {
            "port_id": port_id
        }
    }

    return neutron.update_floatingip(fip_id, data)

if __name__ == '__main__':

    sess = get_session()
    with open('info.txt', 'r') as f:
        for i, line in enumerate(f):
            if i == 1:
                txt_server = line
            elif i == 3:
                txt_cidr = line
            elif i == 5:
                txt_fip = line

    server_uuid = txt_server.strip()
    cidr = txt_cidr.strip().split(',')
    fip_ids = txt_fip.strip().split(',')

    server_info = get_server_info(sess, server_uuid)
    project_id = server_info.tenant_id

    # ============================================================================================
    print "Start adding multiple flp....\n"
    # ============================================================================================

    print "==================================="
    print 'project_id : {}'.format(server_info.tenant_id)
    print 'host_name : {}'.format(server_info._info['name'])
    print 'host_id : {}'.format(server_info._info['id'])
    print 'addresses : {}'.format(server_info._info['addresses'])
    print "==================================="
    continue_flag = raw_input("Are you Sure? (y/n)")
    if continue_flag != "y" :
        print "bye"
        exit()
    print '\n'
    # ============================================================================================

    project_id = server_info.tenant_id
    no_filter_list_of_subnet_id = get_subents(sess, project_id)
    subnet_id = subnet_filter(no_filter_list_of_subnet_id,cidr)

    print "===========list_of_subnet_id=============="
    if not subnet_id:
        print "subnet not found"
        exit()
    for i in range(len(subnet_id)):
        print subnet_id[i]
    print "==========================================\n"

    while(True):
        sg_name = raw_input("what is security group name? : ")
        if sg_name:
            break
    print "===========security_group_id=============="
    security_group_id = get_security_group_id(sess, project_id, sg_name)
    if not security_group_id:
        print "security group not found"
        exit()
    print security_group_id
    print "==========================================\n"

    continue_flag = raw_input("add port? (y/n)")
    if continue_flag != "y" :
        print "bye"
        exit()

    # ============================================================================================

    add_port_through_Toast_api_and_return_port_id(sess, subnet_id, server_uuid, security_group_id)
    print 'port created....\n'

    no_filter_port_id = get_port_id(sess, server_uuid)
    if not no_filter_port_id:
        print "port not found"
        exit()
    port_ids = port_filter(subnet_id, no_filter_port_id)
    print 'new port is {}\n Total : {}\n'.format(port_ids,len(port_ids))

    continue_flag = raw_input("associate fip? (y/n)")
    if continue_flag != "y" :
        print "bye"
        exit()

    for port_id, fip_id in zip(port_ids, fip_ids):
        associate_fip_to_port(sess, fip_id, port_id)

    server_info = get_server_info(sess, server_uuid)
    print "==================================="
    print 'project_id : {}'.format(server_info.tenant_id)
    print 'host_name : {}'.format(server_info._info['name'])
    print 'host_id : {}'.format(server_info._info['id'])
    print 'has security groups : {}'.format(server_info._info['security_groups'])
    print 'addresses : {}'.format(server_info._info['addresses'])
    print "===================================\n"
