#!/bin/sh -eux
# install useful command-line developer tools on centos 7.

# set default value for devops home environment variable if not set. -------------------------------
devops_home="${devops_home:-/opt/cnao-lab-devops}"              # [optional] devops home (defaults to '/opt/cnao-lab-devops').

# create scripts directory (if needed). ------------------------------------------------------------
mkdir -p ${devops_home}/provisioners/scripts/centos
cd ${devops_home}/provisioners/scripts/centos

# install epel repository if needed. ---------------------------------------------------------------
if [ ! -f "/etc/yum.repos.d/epel.repo" ]; then
  rm -f install epel-release-latest-7.noarch.rpm
  wget --no-verbose https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
  yum -y install epel-release-latest-7.noarch.rpm
fi

# install python 2.x pip and setuptools. -----------------------------------------------------------
yum -y install python-pip
python --version
pip --version

# upgrade python 2.x pip.
#pip install --upgrade pip
#pip --version

# install python 2.x setup tools.
yum -y install python-setuptools
#pip install --upgrade setuptools
#easy_install --version

# install software collections library. (needed later for python 3.x.) -----------------------------
yum -y install scl-utils
yum -y install centos-release-scl

# install git. -------------------------------------------------------------------------------------
yum -y install git
git --version
