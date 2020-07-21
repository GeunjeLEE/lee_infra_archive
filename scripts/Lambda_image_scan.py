import json
import logging
import os
import boto3
from base64 import b64decode
from urllib.request import Request, urlopen
from urllib.error import URLError, HTTPError

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def get_text_properties_for_severity(severity_counts):
    """Returns the color setting of severity"""
    if severity_counts['CRITICAL'] != 0:
        properties = {'color': 'danger', 'icon': ':red_circle:'}
    elif severity_counts['HIGH'] != 0:
        properties = {'color': 'warning', 'icon': ':large_orange_diamond:'}
    else:
        properties = {'color': 'good', 'icon': ':green_heart:'}
    return properties

def set_message(scan_result):
    """Slack message formatting"""
    severity_list = ['CRITICAL', 'HIGH', 'MEDIUM', 'LOW', 'INFORMATIONAL', 'UNDEFINED']
    finding_severity_counts = scan_result['detail']['finding-severity-counts']

    for severity in severity_list:
        finding_severity_counts.setdefault(severity, 0)

    message = f"*ECR Image Scan Result | Account:{scan_result['account']} | {scan_result['detail']['repository-name']}:{scan_result['detail']['image-tags'][0]}*"
    text_properties = get_text_properties_for_severity(finding_severity_counts)

    slack_message = {
        'username': 'Amazon ECR',
        'text': message,
        'attachments': [
            {
                'fallback': 'AmazonECR Image Scan Findings Description.',
                'color': text_properties['color'],
                'title': f'''{text_properties['icon']} {
                    scan_result['detail']['scan-status']}''',
                'title_link': f'''https://console.aws.amazon.com/ecr/repositories/{
                    scan_result['detail']['repository-name']}/image/{
                    scan_result['detail']['image-digest']}/scan-results?region={scan_result['region']}''',
                'fields': [
                    {'title': 'Critical', 'value': finding_severity_counts['CRITICAL'], 'short': True},
                    {'title': 'High', 'value': finding_severity_counts['HIGH'], 'short': True},
                    {'title': 'Medium', 'value': finding_severity_counts['MEDIUM'], 'short': True},
                    {'title': 'Low', 'value': finding_severity_counts['LOW'], 'short': True},
                    {'title': 'Info', 'value': finding_severity_counts['INFORMATIONAL'], 'short': True},
                    {'title': 'Undefined', 'value': finding_severity_counts['UNDEFINED'], 'short': True},
                ]
            }
        ]
    }
    return slack_message

def lambda_handler(event, context):
    logger.info("Event: " + str(event))
    HOOK_URL = "https://"
    MESSAGE = set_message(event)
    logger.info("Message: " + str(MESSAGE))

    req=Request(HOOK_URL, json.dumps(MESSAGE).encode('utf-8'))

    try:
        response = urlopen(req)
        response.read()
        logger.info("Message posted")
    except HTTPError as e:
        logger.error("Request failed: %d %s", e.code, e.reason)
    except URLError as e:
        logger.error("Server connection failed: %s", e.reason)
