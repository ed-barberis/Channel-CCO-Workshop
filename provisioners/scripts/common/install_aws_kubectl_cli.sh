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
#kubectl_release="1.28.2"
#kubectl_date="2023-10-17"
#kubectl_sha256="717a48943abe5555093ab7f06232be36e83531406aef44a143473d1975002bc5"
kubectl_release="1.27.6"
kubectl_date="2023-10-17"
kubectl_sha256="41ff242c818bfac0101b24b055ad7a2a5bf48003d195066eb184fb187be48654"
#kubectl_release="1.26.9"
#kubectl_date="2023-10-17"
#kubectl_sha256="7c5d07f988f460297069403ce596435b7ff8392fad0589383f377ec8ae59639b"
#kubectl_release="1.25.14"
#kubectl_date="2023-10-17"
#kubectl_sha256="9542fbf438a32cc618f77895cc585f4979cdb55f1a8a79d6f811e56c62a04922"
#kubectl_release="1.24.17"
#kubectl_date="2023-10-17"
#kubectl_sha256="709443ba7fa723aa171eeff1284fc923c5b6d586bcb7e0d35eeff796f89f27b6"
#kubectl_release="1.23.17"
#kubectl_date="2023-10-17"
#kubectl_sha256="303cb57dee80d1de2dd61bbb8d1d6dd04648a8e7f08bd68933fb01f456314979"

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
case $kubectl_release in
  1.28.2|1.29.0)
    kubectl version --client
    ;;
  *)
    kubectl version --short --client
    ;;
esac

#export KUBECONFIG=$KUBECONFIG:$HOME/.kube/config
