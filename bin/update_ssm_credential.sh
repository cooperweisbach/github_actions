#!/bin/bash

#Log commands to stdout
set -x
#Log errors to stdout
set -e

function usage {
  echo " Usage: update_ssm_credential.sh [-a][-e][-c][-v]"
  echo " -a : Required. Comma seperated list of applications that need a credential updated."
  echo " -e : Required. The environment for which the credential must be updated: dev1, qa1, stg1, trn1, prod."
  echo " -c : Required. The credential that is stored in AWS that must be updated: DB2_JDBC_URL, DB2_JDBC_PASSWORD."
  echo " -v : Required. The value of the credential to update."
  echo "  ? : To view this usage message again."
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
    # Stop logging commands to prevent exposure of plaintext credential value 
    set +x
    if [ -z "${VALUE}" ]; then
      	echo "-v parameter required"
	      valid=false
    fi
    set -x
    
    if [ "${valid}" != true ]; then
        usage
    fi
}

#This function uses the AWS CLI to update the value of the desired parameters with a new value.

function perform_update {
  for app in ${APPLICATIONS[@]}
    do     
      # Stop logging commands to prevent exposure of plaintext credential value
      set +x
      echo "AWS SSM Put Parameter Operation: ${app} - ${ENVIRONMENT} - ${CREDENTIAL}"
      aws ssm put-parameter --name /enterprise-services/${app}/${ENVIRONMENT}/${CREDENTIAL} --value ${VALUE} --overwrite --no-verify-ssl
      set -x
    done
}

#Parse through the supplied values and set variables to reference throughout the script with corresponding value.

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
        --value|-v)
	      # Stop logging commands to prevent exposure of plaintext credential value
	    set +x
            readonly VALUE="$2"
            shift # past argument
	    set -x
        ;;
        *)
            echo "Unknown parameter ${key}"
            usage
            exit 2
        ;;
    esac
    shift # past argument or value
done

#############
# Begin Work
#############

validate_args
perform_update
