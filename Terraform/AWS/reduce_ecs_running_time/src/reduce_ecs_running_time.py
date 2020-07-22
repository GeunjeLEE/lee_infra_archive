import boto3
from botocore.exceptions import ClientError
from datetime import datetime, timedelta, timezone

def stop_or_start(running_flag,cluster_name,service_name,client):
    try:
        request = client.update_service(
            cluster = cluster_name,
            service = service_name,
            desiredCount = 2 if running_flag else 0
        )
        print(request) 
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

        client = boto3.client('ecs')

        for cluster_name, service_name in ecs_list:
            stop_or_start(running_flag,cluster_name,service_name,client)

    except ClientError as e:
        print("exceptin: %s" % e)
