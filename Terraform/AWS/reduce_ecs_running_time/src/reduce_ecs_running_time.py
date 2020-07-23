import boto3
from botocore.exceptions import ClientError
from datetime import datetime, timedelta, timezone

# declare boto3 client as a global variable
ecs_client = boto3.client('ecs')
autoscaling_client = boto3.client('application-autoscaling')

def delete_autoscaling_policy(cluster_name,service_name):
    try:
        # get TargetValue for registering TargetValue with tags in the ecs autoscaling policy
        response = autoscaling_client.describe_scaling_policies(
            PolicyNames=['cpu-scale-out'],
            ServiceNamespace='ecs',
            ResourceId='service/{}/{}'.format(cluster_name,service_name),
            ScalableDimension='ecs:service:DesiredCount',
        )
        TargetValue = str(response['ScalingPolicies'][0]['TargetTrackingScalingPolicyConfiguration']['TargetValue'])

        # register the TargetValue tag to the Ecs service
        response = ecs_client.describe_services(
                cluster=cluster_name,
                services=[
                    service_name,
                ]
            )
        clusterArn = response['services'][0]['clusterArn']
        ecs_client.tag_resource(
            resourceArn=clusterArn,
            tags=[
                {
                    'key': 'AutoScailing_TargetValue',
                    'value': TargetValue
                }
            ]
        )

        # delete autoscaling policy
        response = autoscaling_client.delete_scaling_policy(
            PolicyName='cpu-scale-out',
            ServiceNamespace='ecs',
            ResourceId='service/{}/{}'.format(cluster_name,service_name),
            ScalableDimension='ecs:service:DesiredCount'
        )
        print(response)
    except ClientError as e:
        print("exceptin: %s" % e)

def put_autoscaling_policy(cluster_name,service_name):
    try:
        # get TargetValue from ecs service tag
        response = ecs_client.describe_clusters(
            clusters=[cluster_name],
            include=[
                'TAGS',
            ]
        )
        TargetValue_from_tag = int(float(response['clusters'][0]['tags'][0]['value']))

        # delete TargetValue tag from ecs service
        response = ecs_client.describe_services(
                cluster=cluster_name,
                services=[
                    service_name,
                ]
            )
        clusterArn = response['services'][0]['clusterArn']
        ecs_client.untag_resource(
            resourceArn=clusterArn,
            tagKeys=[
                'AutoScailing_TargetValue',
            ]
        )

        # put autoscaling policy
        response = autoscaling_client.put_scaling_policy(
            PolicyName='cpu-scale-out',
            ServiceNamespace='ecs',
            ResourceId='service/{}/{}'.format(cluster_name,service_name),
            ScalableDimension='ecs:service:DesiredCount',
            PolicyType='TargetTrackingScaling',
            TargetTrackingScalingPolicyConfiguration={
                'TargetValue': TargetValue_from_tag,
                'PredefinedMetricSpecification': {
                    'PredefinedMetricType': 'ECSServiceAverageCPUUtilization'
                },
                'ScaleOutCooldown': 300,
                'ScaleInCooldown': 300,
                'DisableScaleIn': False
            }
        )
    except ClientError as e:
        print("exceptin: %s" % e)

def stop_or_start(running_flag,cluster_name,service_name):
    try:

        # delete or put autoscaling_policy before adjust desiredCount
        if running_flag:
            put_autoscaling_policy(cluster_name,service_name)
        else:
            delete_autoscaling_policy(cluster_name,service_name)

        # adjust desiredCount to 0 or 2
        response = ecs_client.update_service(
            cluster = cluster_name,
            service = service_name,
            desiredCount = 2 if running_flag else 0
        )
        print(response)
    except ClientError as e:
        print("exceptin: %s" % e)


def lambda_handler(event, context):
    try:
        JST = timezone(timedelta(hours=+9), 'JST')
        current_hour = datetime.now(JST).hour
        ecs_list = [
            ['lee-cluster','bg-web-service']
        ]

        # 07:00~17:59 = running
        if current_hour >= 7 and current_hour < 18:
            running_flag = True
        else:
            running_flag = False

        for cluster_name, service_name in ecs_list:
            stop_or_start(running_flag,cluster_name,service_name)

    except ClientError as e:
        print("exceptin: %s" % e)
