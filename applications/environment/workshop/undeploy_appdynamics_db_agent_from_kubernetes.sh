#!/bin/bash

#
# Script to undeploy the AppDynamics Database Agent from the IKS Kubernetes cluster.
#
# set default values for input environment variables if not set. -----------------------------------
# [MANDATORY] appdynamics agents undeploy parameters [w/ defaults].
iks_kubeconfig_filepath="${iks_kubeconfig_filepath:-}"

kubectl delete -f db-agent.yaml --kubeconfig $iks_kubeconfig_filepath

kubectl delete -f db-log-config.yaml --kubeconfig $iks_kubeconfig_filepath

kubectl delete -f db-config.yaml --kubeconfig $iks_kubeconfig_filepath

