#!/bin/bash

set -x
set -e

function usage {
  echo "Action Based On Faulty Step <-s> <-c>"
  echo "-s | --step : Required. The name of the faulty step."
  echo "-c | --conclusion : Required. The conclusion of the faulty step. Will be either \'cancelled\' or \'failed\'."
  echo "? : Usage function called. "
  exit 255
}

function determine_action {
  local stepName="$1"
  local stepConclusion="$2"
  
  case $stepName in 
       stop_ecs)
            echo "Failed Stop ECS"
            if [ "$stepConclusion" == "cancelled" ]; then
                bin/update_ecs_desired_count.sh -e ${{ github.event.inputs.environment }} -a ${{ github.event.inputs.applications }}  -m restore
            fi
            ;;
       manual_validation)
            bin/update_ecs_desired_count.sh -e ${{ github.event.inputs.environment }} -a ${{ github.event.inputs.applications }}  -m restore
            ;;
       update_ssm_parameters)
            if [ "$stepConclusion" == "failed" ]; then
                bin/update_ecs_desired_count.sh -e ${{ github.event.inputs.environment }} -a ${{ github.event.inputs.applications }}  -m restore
            fi
            ;;
       restore_count)
             echo "Restore count failed...attempting a second time. Please check via AWS console that the ECS services are back up running."
             bin/update_ecs_desired_count.sh -e ${{ github.event.inputs.environment }} -a ${{ github.event.inputs.applications }}  -m restore
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
       *)
            echo "Unknown parameter ${key}"
            usage
            exit 2
        ;;
    esac
    shift # past argument or value
done

determine_action $STEP $CONCLUSION
