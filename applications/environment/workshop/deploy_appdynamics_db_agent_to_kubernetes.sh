#!/bin/bash

#
# Script to deploy the AppDynamics Database Agent to the IKS Kubernetes cluster.
#
# set default values for input environment variables if not set.
# [MANDATORY] appdynamics agents deploy parameters [w/ defaults].
iks_kubeconfig_filepath="${iks_kubeconfig_filepath:-}"


kubectl apply -f db-log-config.yaml --kubeconfig $iks_kubeconfig_filepath

kubectl apply -f db-config.yaml --kubeconfig $iks_kubeconfig_filepath

kubectl apply -f db-agent.yaml --kubeconfig $iks_kubeconfig_filepath

echo "Pausing for 10 seconds..."
sleep 10
