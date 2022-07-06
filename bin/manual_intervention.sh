#!/bin/bash

set -x
set -e

function usage {
    echo "Usage: manual_intervention.sh - Creates an issue with the repository and waits for that issue to be resolved. "
    echo "  -g | --github-token : Required. The token used to make API calls to GH."
    echo "  -t | --triggered-by : Required. The individual. "
    echo "  ?  : Display this usage message."
    exit 255
}

function create_issue {
    curl --silent \
      -X POST \
      -H "Accept: application/vnd.github.v3+json" \
      -H "Authorization: token ${GITHUB_TOKEN}"
      https://api.github.com/repos/cooperweisbach/github_actions/issues \
      -d '{"title":"Manual Validation - SSM Update","body":"This issue was created to include manual validation in the process to update SSM parameters", "assignees":["${TRIGGERED_BY}"]}' |
      grep number | awk -F ':' '{print $2}' | sed 's/ *//g' | sed 's/,//g'
}      

function poll_for_resolution {
    echo $1
    local resolved=false
    local iterator=0
     while [[ ! resolved ]]
     do
      sleep 15s
      curl \
      -H "Accept: application/vnd.github.v3+json" \
      -H "Authorization: token ${GITHUB_TOKEN}"
      https://api.github.com/repos/cooperweisbach/github_actions/issues/$1 |
      grep -fw - 'state:' | awk -F ':' '{print $2}' | sed 's/ *//g' | sed 's/,//g'
      
      iterator++
      if [[ iterator = 20 ]]; then
        echo "Manual action timed out...issue wasn't resolved in under 5 minutes"
        exit 255
      fi
      done
}

global_issue_number=create_issue
poll_for_resolution global_issue_number
