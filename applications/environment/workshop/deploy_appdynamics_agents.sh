#!/bin/bash

#
# Script to deploy AppDynamics Agents to two different Kubernetes clusters using a Helm chart.
# This script uses the AD-Workshop-Utils.jar to perform the deployment with elevated permissions.
#
# The Helm chart is configured to deploy the following agent types:
#
# - Cluster Agent
# - Java Agent
# - ServerMonitoring Agent
# - NetViz Agent
#

appd_wrkshp_last_setupstep_done="100"

java -DworkshopUtilsConf=./agent-setup.yaml -DworkshopAction=elevatedinstall -DlastSetupStepDone=${appd_wrkshp_last_setupstep_done} -DshowWorkshopBanner=false -jar ./AD-Workshop-Utils.jar

rm -f values-ca1.yaml
