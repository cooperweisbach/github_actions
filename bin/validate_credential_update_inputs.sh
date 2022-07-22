#!/bin/bash

set -x
set -e


function usage {
  echo "validate_credential_update_inputs.sh <-e> <-a> <-c>"
  echo "-e | --environment : The environment input"
  echo "-a | --applications : The applications input"
  echo "-c | --credential : The credential input"
  echo "? : Usage function"
  exit 255
}

#This function will validate that all the arguments that are required are passed upon invocation of the script.
#This function should be the first form of validation that is run.

function validate_args {
     local valid=true

    if [ -z "${APPLICATIONS[@]}" ]; then
        echo "-a parameter required"
        valid=false
    fi

    if [ -z "${ENVIRONMENT}" ]; then
        echo "-e parameter required"
        valid=false
    fi

    if [ -z "${CREDENTIAL}" ]; then
      	echo "-c parameter required"
	      valid=false
    fi
    if [ "${valid}" != true ]; then
        usage
    fi
}

#This function will check that all the apps that have been entered as input exist in the source directory.
#This function should run before validate_parameters_exist.
#This is necessary because no credentials will exist for an invalid app.

function validate_apps_exist {
    for app in ${APPLICATIONS[@]}
      do
	      echo $app
        if [ ! -d "./app/${app}" ]; then
	          echo "${app} not found"
            exit 1
        fi
      done
}


#This function will check that all the parameters that will potentially be updated, actually exist using the AWS CLI.
#This function should run before perform_update.
#This is necessary to ensure that the entire transaction can occur.

function validate_parameters_exist {
  for app in ${APPLICATIONS[@]}
    do     
      set +x
      echo "AWS SSM Get Parameter Operation: ${app} - ${ENVIRONMENT} - ${CREDENTIAL}"
               #Get the parameter from AWS and silence the output through redirection 
      aws ssm get-parameter --name /enterprise-services/${app}/${ENVIRONMENT}/${CREDENTIAL} > /dev/null
      set -x
    done
}


while [[ $# -gt 0 ]]
do
    key="$1"
    case $key in
        --applications|-a)
	    readarray -td, APPLICATIONS <<<"$2,"; unset 'APPLICATIONS[-1]'; declare -p APPLICATIONS;
            readonly APPLICATIONS
            shift # past argument
        ;;
        --environment|-e)
            readonly ENVIRONMENT="$2"
            shift # past argument
        ;;
        --credential|-c)
            readonly CREDENTIAL="$2"
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


validate_args
validate_apps_exist
validate_parameters_exist
