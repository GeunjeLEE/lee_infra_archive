#!/bin/bash

amazon-ssm-agent -register -code "${AGENT_CODE}" -id "${AGENT_ID}" -region "${AWS_DEFAULT_REGION}" 
amazon-ssm-agent
