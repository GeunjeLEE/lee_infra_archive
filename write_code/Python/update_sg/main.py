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
    target_ip = "123.123.123.123/32"
    has_mz_office_sg_list = []
    for security_group_rule in security_group_rules['SecurityGroupRules']:
        ret = {}
        if target_ip in security_group_rule.values():
            ret['GroupId']              = security_group_rule['GroupId']
            ret['SecurityGroupRuleId']  = security_group_rule['SecurityGroupRuleId']
            ret['IpProtocol']           = security_group_rule['IpProtocol']
            ret['FromPort']             = security_group_rule['FromPort']
            ret['ToPort']               = security_group_rule['ToPort']
            has_mz_office_sg_list.append(ret)

    return has_mz_office_sg_list

def update_ingress_rule(client, has_mz_office_sg):
    group_id                = has_mz_office_sg['GroupId']
    security_group_rule_id  = has_mz_office_sg['SecurityGroupRuleId']
    ip_protocol             = has_mz_office_sg['IpProtocol']
    from_port               = has_mz_office_sg['FromPort']
    to_port                 = has_mz_office_sg['ToPort']
    cidr_ipv4               = "ipv4/32"
    description             = "description"

    try:
        response = client.modify_security_group_rules(
            GroupId=group_id,
            SecurityGroupRules=[
                {
                    'SecurityGroupRuleId': security_group_rule_id,
                    'SecurityGroupRule': {
                        'IpProtocol': ip_protocol,
                        'FromPort': from_port,
                        'ToPort': to_port,
                        'CidrIpv4': cidr_ipv4,
                        'Description': description
                    }
                },
            ],
            DryRun=False
        )
        print(response)
    except ClientError as e:
        print(f'{group_id} : {security_group_rule_id}')
        raise e

client = get_client("AWS_ACCESS_KEY", "AWS_ACCESS_SECRET")
security_group_rules = get_all_security_group_rules(client)
has_mz_office_list = find_sg_has_MZ_office_ip(security_group_rules)

for modified_information in has_mz_office_list:
    update_ingress_rule(client,modified_information)





