import boto3
from botocore.exceptions import ClientError

def get_client(aws_access_key_id,aws_secret_access_key):
    client = boto3.client(
        'ec2',
        aws_access_key_id=aws_access_key_id,
        aws_secret_access_key=aws_secret_access_key,
        region_name='ap-northeast-2'
    )

    return client

def get_all_security_group_rules(client):
    try:
        response = client.describe_security_group_rules()
        return response
    except ClientError as e:
        raise e

def find_sg_has_MZ_office_ip(security_group_rules):
    target_ip_list = ["target_ip"]
    has_mz_office_sg_list = []
    for security_group_rule in security_group_rules['SecurityGroupRules']:
        ret = {}
        cidr = security_group_rule.get("CidrIpv4", None)
        if cidr and cidr in target_ip_list:
            ret['GroupId']              = security_group_rule['GroupId']
            ret['SecurityGroupRuleId']  = security_group_rule['SecurityGroupRuleId']
            ret['IpProtocol']           = security_group_rule['IpProtocol']
            ret['FromPort']             = security_group_rule['FromPort']
            ret['ToPort']               = security_group_rule['ToPort']
            ret['CidrIpv4']             = security_group_rule['CidrIpv4']
            has_mz_office_sg_list.append(ret)

    return has_mz_office_sg_list

def revoke_ingress_rule(client, group_id, rule_id):
    try:
        response = client.revoke_security_group_ingress(
            GroupId=group_id,
            SecurityGroupRuleIds=[rule_id]
        )
        print(response)
    except ClientError as e:
        raise e

client = get_client("api", "secret")

security_group_rules = get_all_security_group_rules(client)
delete_list = find_sg_has_MZ_office_ip(security_group_rules)

print(delete_list)

# for list in delete_list:
#     revoke_ingress_rule(client,list['GroupId'],list['SecurityGroupRuleId'])