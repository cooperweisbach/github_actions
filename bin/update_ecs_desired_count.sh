#!/bin/bash

#Log commands to stdout
set -x
#Log errors to stdout
set -e

###############
# Functions
###############
function usage {
  echo "Usage: set_ecs_desired_count_0.sh [-a][-e][-m]"
  echo "  -a : Required. The list of applications that need to have thier desired count reduced."
  echo "  -e : Required. The environment that is being adjusted: dev1, qa1, stg1, trn1, prod."
  echo "  -m : Required. Mode in which this script will execute: reduce, return, where reduce sets counts to 0 and return will return counts to configured values."
  echo "   ? : Display this usage message."
  exit 225
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

    if  [ -z "${MODE}" ]; then
	echo "-m parameter required"
	valid=false
    fi

    if [ "${valid}" != true ]; then
        usage
    fi
}

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

function change_desired_count {
    for app in ${APPLICATIONS[@]}
       do
          if [ ${MODE} == "reduce" ]; then
	      echo "reducing ecs count for ${app} to 0"
              aws ecs update-service --cluster es-springboot-${ENVIRONMENT}-cluster --service ${app} --desired-count 0 
#             > /dev/null
          else
              returnValue=$( grep "task_count" ./app/${app}/infrastructure/unprotected/${ENVIRONMENT}/main.tf | awk -F '=' '{print $2}' | sed 's/ //g' )
	      echo "returning ecs count for ${app} to ${returnValue}"
              aws ecs update-service --cluster es-springboot-${ENVIRONMENT}-cluster --service ${app} --desired-count ${returnValue} 
#	      > /dev/null
         fi
       done
}
#############################
# Command line arguments
#############################

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
        --mode|-m)
            readonly MODE="$2"
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


#############
# Begin Work
#############

validate_args
validate_apps_exist
change_desired_count
