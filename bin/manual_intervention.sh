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
     echo $( curl --silent \
      -X POST \
      -H "Accept: application/vnd.github.v3+json" \
      -H "Authorization: token ${GITHUB_TOKEN}" \
      https://api.github.com/repos/cooperweisbach/github_actions/issues \
      -d '{"title":"Manual Validation - SSM Update","body":"This issue was created to include manual validation in the process to update SSM parameters", "assignees":['\""$TRIGGERED_BY"\"']}' |
      grep number | awk -F ':' '{print $2}' | sed 's/ *//g' | sed 's/,//g' )
}      

function poll_for_resolution {
    echo $1
    local resolved=open
    local iterator=0
    while [ "$resolved" != "closed" ]
    do
       sleep 15s
       resolved=$( curl --silent \
       -H "Accept: application/vnd.github.v3+json" \
       -H "Authorization: token ${GITHUB_TOKEN}" \
       https://api.github.com/repos/cooperweisbach/github_actions/issues/$1 |
       grep -w 'state' | awk -F ':' '{print $2}' | sed 's/ *//g' | sed 's/,//g' | sed 's/"//g' )

       echo $resolved

       iterator=$( expr $iterator + 1 )
       if [ $iterator = 20 ]; then
         curl --silent \
         -X PATCH -H "Accept: application/vnd.github.v3+json" -H "Authorization: token ${GITHUB_TOKEN}" \
         https://api.github.com/repos/cooperweisbach/github_actions/issues/$1 \
         -d '{"state":"closed"}'
         echo "Manual action timed out...issue wasn't resolved in under 1 minute"
         exit 255
       fi
    done
}


while [[ $# -gt 0 ]]
do
    key="$1"
    case $key in
        --github-token|-g)
            readonly GITHUB_TOKEN="$2"
            shift # past argument
        ;;
        --triggered-by|-t)
            readonly TRIGGERED_BY="$2"
            shift # past argument
        ;;
        *)
            echo "Unknown parameter ${key}"
            usage
            exit 2
        ;;
    esac
    shift # past argument or value
done



global_issue_number=$( create_issue )
echo $global_issue_number
poll_for_resolution $global_issue_number
