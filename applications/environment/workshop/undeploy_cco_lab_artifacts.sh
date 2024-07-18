#!/bin/bash

echo "Removing Application"
helm uninstall ${cco_lab_id}-otel-demo -n $cco_lab_id --wait
echo "Done"

echo "Removing $cco_lab_id Namespace"
kubectl delete namespace $cco_lab_id
echo "Done"

echo "Removing AppDynamics Collectors"
helm uninstall appdynamics-collectors -n appdynamics --wait
echo "Done"

echo "Removing AppDynamics Operators"
helm uninstall appdynamics-operators -n appdynamics --wait
echo "Done"

echo "Removing AppDynamics Namespace"
kubectl delete namespace appdynamics
echo "Done"

echo "Removing Cert Manager"
kubectl delete -f https://github.com/cert-manager/cert-manager/releases/download/v1.15.1/cert-manager.yaml
echo "Done"

echo "Cleaning up Helm Repo"
repos=$(helm repo list | awk 'NR>1 {print $1}')
for repo in $repos; do
  helm repo remove $repo
done
echo "Done"

echo "Removing Collector YAML files"
rm collectors-values*
echo "Done"

echo "Removing Operators YAML files"
rm operators-values*
echo "Done"

echo "Resetting Kubectl Context"
kubectl config unset current-context
contexts=$(kubectl config get-contexts -o name)
for context in $contexts; do
  kubectl config delete-context "$context"
done
rm ~/.kube/config
echo "Done"
