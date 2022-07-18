#!/bin/bash

set -x
set -e

function usage {
  echo "Action Based On Faulty Step <-s> <-c>"
  echo "-s | --step : Required. The name of the faulty step."
  echo "-c | --conclusion : Required. The conclusion of the faulty step. Will be either \'cancelled\' or \'failed\'."
  echo "-e | --environment : Required. The environment that was supposed to be updated."
  echo "-a | --applications : Required. The applications that were supposed to be updated."
  echo "? : Usage function called. "
  exit 255
}

function determine_action {
  local stepName="$1"
  local stepConclusion="$2"
  
  case $stepName in 
       stop_ecs)
            if [ "$stepConclusion" == "cancelled" ]; then
              echo "Made it to Cancelled - stop_ecs"
              bin/update_ecs_desired_count.sh -e $ENVIRONMENT -a $APPLICATIONS -m restore
            fi
            ;;
       manual_intervention)
             echo "Made it to faulty Manual Validation"
             bin/update_ecs_desired_count.sh -e $ENVIRONMENT -a $APPLICATIONS -m restore
            ;;
       update_ssm_parameters)
            if [ "$stepConclusion" == "failed" ]; then
                  echo "Made it to Failed - Update_SSM_Parameters"
                  bin/update_ecs_desired_count.sh -e $ENVIRONMENT -a $APPLICATIONS -m restore
            fi
            ;;
       restore_count)
             echo "Restore count failed...attempting a second time. Please check via AWS console that the ECS services are back up running."
             bin/update_ecs_desired_count.sh -e $ENVIRONMENT -a $APPLICATIONS  -m restore
             ;;
   esac
}

while [[ $# -gt 0 ]]
do
    key="$1"
    case $key in
      --conclusion | -c)
          readonly CONCLUSION="$2"
          shift
       ;;
      --step | -s)
          readonly STEP="$2"
          shift
       ;;
      --environment | -e)
          readonly ENVIRONMENT="$2"
          shift
       ;;
      --applications | -a)
          readonly APPLICATIONS="$2"
          shift
       ;;
       *)
            echo "Unknown parameter ${key}"
            usage
            exit 2
        ;;
    esac
    shift # past argument or value
done

determine_action $STEP $CONCLUSION
