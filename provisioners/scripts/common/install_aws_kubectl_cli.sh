#!/bin/sh -eux
#---------------------------------------------------------------------------------------------------
# Install kubectl CLI for Amazon EKS.
#
# Kubernetes uses a command-line utility called kubectl for communicating with the cluster
# API server to deploy and manage applications on Kubernetes. Using kubectl, you can inspect
# cluster resources; create, delete, and update components; look at your new cluster; and
# bring up example apps.
#
# For more details, please visit:
#   https://kubernetes.io/docs/concepts/
#   https://kubernetes.io/docs/tasks/tools/install-kubectl/
#
# NOTE: Script should be run with 'root' privilege.
#---------------------------------------------------------------------------------------------------

# install kubectl cli. -----------------------------------------------------------------------------
#kubectl_release="1.28.1"
#kubectl_date="2023-09-14"
#kubectl_sha256="7a6561cd5ba6a601fd790123e39fb00e49572445bf1d7ed573d65fec9ce4a300"
kubectl_release="1.27.5"
kubectl_date="2023-09-14"
kubectl_sha256="c19063ccf5b3042b641f889e9106befdaee913efce500eb69647caa1133a2804"
#kubectl_release="1.26.8"
#kubectl_date="2023-09-14"
#kubectl_sha256="7fc29627d746e46afe8080a817be56f7ff2d5745de56875a7c4923b7f7625db3"
#kubectl_release="1.25.13"
#kubectl_date="2023-09-14"
#kubectl_sha256="0ea698b87184260a984d2fcfbb6c06d22820b3ef37c6b41fdbb15f3b944d4e21"
#kubectl_release="1.24.17"
#kubectl_date="2023-09-14"
#kubectl_sha256="ad5d619779aadfe219bb34bf044c53184040b90100e950c0373e1a7c7d69bfc9"
#kubectl_release="1.23.17"
#kubectl_date="2023-09-14"
#kubectl_sha256="c24f547a0ad520ffbde037f0e3e57059872d7e0140bc9f9b84e59bdc906b67bd"

# create local bin directory (if needed).
mkdir -p /usr/local/bin
cd /usr/local/bin

# download kubectl binary from github.com.
rm -f kubectl
curl --silent --location "https://s3.us-west-2.amazonaws.com/amazon-eks/${kubectl_release}/${kubectl_date}/bin/linux/amd64/kubectl" --output kubectl 
chown root:root kubectl

# verify the downloaded binary.
echo "${kubectl_sha256} kubectl" | sha256sum --check
# kubectl: OK

# change execute permissions.
chmod 755 kubectl

# set kubectl environment variables.
PATH=/usr/local/bin:$PATH
export PATH

# verify installation.
kubectl version --short --client

#export KUBECONFIG=$KUBECONFIG:$HOME/.kube/config
