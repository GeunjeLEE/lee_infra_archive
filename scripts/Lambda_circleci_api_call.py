import json
import logging
import os
import urllib.request
import base64
logger = logging.getLogger()
logger.setLevel(logging.DEBUG)
def lambda_handler(event, context):
    url = "https://circleci.com/api/v2/project/{project_slug}/pipeline"
    method = "POST"
    branch = "{branch_bame}"
    basic_auth_token = base64.b64encode('{}'.format(os.environ['PERSONAL_API_TOKEN']).encode('utf-8'))
    headers = {
        "Content-Type" : "application/json",
        "Authorization": "Basic " + basic_auth_token.decode('utf-8')
        }
    data = {
        "branch":branch
        } 
    request = urllib.request.Request(url, data=json.dumps(data).encode(), method=method, headers=headers)
    with urllib.request.urlopen(request) as res:
        body = res.read()
        return body
