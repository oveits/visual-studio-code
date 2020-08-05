#!/usr/bin/env bash
set -e

APPLICATION_NAME=${APPLICATION_NAME:="Visual Studio Code"}
DEPLOYMENT_YAML_FILE_PATH=${DEPLOYMENT_YAML_FILE_PATH:=deploy/deploy.yaml}
POD_PATTERN=visual

a=no
read -p "are you sure? This will restart the current ${APPLICATION_NAME} container (yes|no)> " a

[ "$(echo $a | cut -c 1)" == "y" ] || [ "$(echo $a | cut -c 1)" == "Y" ] \
  && IMAGE=$(cat ${DEPLOYMENT_YAML_FILE_PATH} | egrep "^[ ]*image:" | awk '{print $2}') \
  && sudo docker build -t ${IMAGE} . \
  && sudo docker push ${IMAGE} \
  && OLD_POD=$(kubectl get pod | awk '{print $1}' | grep ${POD_PATTERN}) \
  && bash deploy.sh \
  && kubectl delete POD $OLD_POD \
  && watch kubectl get pod

