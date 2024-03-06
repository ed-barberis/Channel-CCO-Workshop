#!/bin/bash -eu
#---------------------------------------------------------------------------------------------------
# Enable CCO Collectors Logging configuration.
#
# The Cisco AppDynamics Kubernetes and App Service Monitoring with Cisco Cloud Observability (CCO)
# provides a solution to monitor applications and infrastructure with correlation using Helm Charts.
#
# To simplify deployment of these Helm Charts with Logging enabled, this script will extract key
# values from the # downloaded 'collectors-values.yaml' and add a Logging configuration for the
# OTel Demo application.
#
# To execute this script, you will need the following:
#   'collectors-values.yaml' file:     Download/upload to your local home directory from CCO.
#   yq:                                'yq' is a command-line YAML processor for linux 64-bit.
#
# For more details, please visit:
#   https://docs.appdynamics.com/fso/cloud-native-app-obs/en/kubernetes-and-app-service-monitoring
#   https://docs.appdynamics.com/fso/cloud-native-app-obs/en/kubernetes-and-app-service-monitoring/install-kubernetes-and-app-service-monitoring#InstallKubernetesandAppServiceMonitoring-helm-chartsInstallKubernetesandAppServiceMonitoringUsingHelmCharts
#   https://mikefarah.gitbook.io/yq/
#
# NOTE: Script can be run without elevated user privileges.
#---------------------------------------------------------------------------------------------------

# validate that the helm chart has been generated and downloaded. ----------------------------------
# check if 'collectors-values.yaml' file exists.
if [ ! -f "collectors-values.yaml" ]; then
  echo "ERROR: 'collectors-values.yaml' file NOT found."
  echo "Please generate and download from your Cisco Cloud Observability Tenant."
  echo "For more information, visit:"
  echo "  https://docs.appdynamics.com/fso/cloud-native-app-obs/en/kubernetes-and-app-service-monitoring"
  exit 1
fi

# validate required binaries. ----------------------------------------------------------------------
# check if 'yq' is installed.
if [ ! $(command -v yq) ]; then
  echo "ERROR: 'yq' command-line YAML processor utility NOT found."
  echo "NOTE: This script uses the 'yq' command-line YAML processor utility for extracting values from the downloaded Helm charts."
  echo "      For more information, visit: https://mikefarah.gitbook.io/yq/"
  echo "                                   https://github.com/mikefarah/yq/"
  echo "                                   https://github.com/mikefarah/yq/releases/"
  exit 1
fi

# set current date for temporary filename. ---------------------------------------------------------
curdate=$(date +"%Y-%m-%d.%H-%M-%S")

# start processing the helm charts. ----------------------------------------------------------------
# print start message.
echo "Begin processing Helm Chart files..."

# create backups of the helm chart values files. ---------------------------------------------------
cp -p collectors-values.yaml collectors-values.yaml.${curdate}

# extract helm chart values from 'collectors-values.yaml'. -----------------------------------------
echo "Extracting CCO configuration values..."
client_id=$(yq '.appdynamics-otel-collector.clientId' collectors-values.yaml)
client_secret=$(yq '.appdynamics-otel-collector.clientSecret' collectors-values.yaml)
cluster_name=$(yq '.global.clusterName' collectors-values.yaml)
collector_endpoint=$(yq '.appdynamics-otel-collector.endpoint' collectors-values.yaml)
token_url=$(yq '.appdynamics-otel-collector.tokenUrl' collectors-values.yaml)
echo ""

echo "client_id: ${client_id}"
echo "client_secret: ${client_secret}"
echo "cluster_name: ${cluster_name}"
echo "collector_endpoint: ${collector_endpoint}"
echo "token_url: ${token_url}"
echo ""

# create new 'collectors-values-with-logging.yaml' file with logging configuration. ----------------
echo "Creating new 'collectors-values-with-logging.yaml' file with logging configuration..."
rm -f collectors-values-with-logging.yaml

cat <<EOF > collectors-values-with-logging.yaml
global:
  clusterName: ${cluster_name}
  oauth:
    clientId: ${client_id}
    clientSecret: ${client_secret}
    endpoint: ${collector_endpoint}
    tokenUrl: ${token_url}
appdynamics-cloud-k8s-monitoring:
  install:
    clustermon: true
    defaultInfraCollectors: true
    logCollector: true
  clustermonConfig:
    os: linux
    events:
      enabled: true
      severityToExclude: []
      reasonToExclude: []
      severeGroupByReason: []
  containermonConfig:
    os:
      - linux
  servermonConfig:
    os:
      - linux
  logCollectorConfig:
    os:
      - linux
    container:
      logging:
        level: debug
      conditionalConfigs:
        - condition:
            operator: contains
            key: kubernetes.pod.name
            value: ad-service
          config: # new
            messageParser:
              log4J:
                enabled: true
                pattern: "%d{yyyy-MM-dd HH:mm:ss} - %logger{36} - %msg trace_id=%X{trace_id} span_id=%X{span_id} trace_flags=%X{trace_flags} %n"
            multiLineMatch: after
            multiLinePattern: '^\d{4}-\d{2}-\d{2}'
            multiLineNegate: true # default is false
      dropFields: ["agent", "stream", "ecs", "input", "orchestrator", "k8s.annotations.appdynamics", "k8s.labels", "k8s.node.labels", "cloud"]
      batchSize: 1000
      maxBytes: 1000000
appdynamics-otel-collector:
  clientId: ${client_id}
  clientSecret: ${client_secret}
  endpoint: ${collector_endpoint}
  tokenUrl: ${token_url}
  enableNetworkMonitoring: true
appdynamics-network-monitoring:
  enabled: true
EOF
echo ""

# print completion message.
echo "CCO Collectors file: 'collectors-values-with-logging.yaml' created."
echo "Enable CCO Collectors Logging configuration operation complete."
