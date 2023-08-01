#!/bin/sh -eux
# install python 3.8 from the software collection library for linux 7.x..

# set default value for cnao lab devops home environment variable if not set. ----------------------
devops_home="${devops_home:-/opt/cnao-lab-devops}"  # [optional] cnao lab devops home folder (defaults to '/opt/cnao-lab-devops').

# create scripts directory (if needed). ------------------------------------------------------------
mkdir -p ${devops_home}/provisioners/scripts/centos
cd ${devops_home}/provisioners/scripts/centos

# install python 3.8. ------------------------------------------------------------------------------
yum -y install rh-python38

# verify installation.
scl enable rh-python38 -- python --version

# install python 3.8 pip. --------------------------------------------------------------------------
rm -f get-pip.py
wget --no-verbose https://bootstrap.pypa.io/get-pip.py
scl enable rh-python38 -- python ${devops_home}/provisioners/scripts/centos/get-pip.py

# verify installation.
scl enable rh-python38 -- pip --version
scl enable rh-python38 -- pip3 --version
