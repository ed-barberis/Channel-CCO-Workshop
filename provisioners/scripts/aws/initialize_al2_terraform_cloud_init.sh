#!/bin/sh -eux
# appdynamics aws cnao lab cloud-init script to initialize aws ec2 instance launched from ami.

# set default values for input environment variables if not set. -----------------------------------
# [OPTIONAL] aws user and host name config parameters [w/ defaults].
user_name="${user_name:-ec2-user}"
aws_ec2_hostname="${aws_ec2_hostname:-cnao-lab-vm}"
aws_ec2_domain="${aws_ec2_domain:-localdomain}"
aws_region_name="${aws_region_name:-us-east-2}"
use_aws_ec2_num_suffix="${use_aws_ec2_num_suffix:-true}"
aws_eks_cluster_name="${aws_eks_cluster_name:-cnao-lab-xxxxx-eks-cluster}"

# configure public keys for specified user. --------------------------------------------------------
user_home=$(eval echo "~${user_name}")
user_authorized_keys_file="${user_home}/.ssh/authorized_keys"
user_key_name="Channel-CNAO-Workshop"
user_public_key="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCkVnb7a69d+MSRG08WdqfvWXEpnT544XzohdZ0sIs5fRLU+pAh48F+BieIqxvCUKIUDXQFP04iQmoo5MKiLH42YVfDmsoidLDejiDS0O5KTn8DS6jA2akeT19xpYweKmRcw4kz+DeBe9dmYmggGQYZx48bSwBrwHcjvJciYTbLyBxmTx/kUIfn4Ub81cfoKq/m5qh/LnyZsXo+ZWj6kGDWsqSpX3I0jysaEsvQDRoRUUe0gSPIe7Y3IfTLsCj0PxzFMDqASeHMMGGoBzMhdWXexiDCUIcToGRKTC6FVfDEZs1kTYKJe7hp0CJtZHMdM7yAhb1JSAURT6ZcOwopxIH7 Channel-CNAO-Workshop"

# 'grep' to see if the user's public key is already present, if not, append to the file.
grep -qF "${user_key_name}" ${user_authorized_keys_file} || echo "${user_public_key}" >> ${user_authorized_keys_file}
chmod 600 ${user_authorized_keys_file}

aws_cloud9_key_name="ed.barberis+975944588697@cloud9.amazon.com"
aws_cloud9_public_key="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDeV+SMmfQyUXpr9SfKDMZg0QWTg5X/ymBv0Yu7dDkDCzLRJRoQpJh2Dk3/Aumegz1sxyWQnha5Lfpj9sE2tYq6k9qJnCF1efsEG8Lgc3wyBojNfiW6v8N5ekn9ZqzodC+rNhteTitI5BePvnTZmWJBNmz5aUUlQKfQqtSgW/xJy7mWsGzHgLkUhcaFjfugOW1zDkSEJdqclAFhVhnYbxuM4ecF1LiS5iWy2I/BenysUyN9ChFVhMtYSNORDo/0E4ftti+iFPbbupzGyE2nwCIc4SammIOEqm7DLwmUBfxI47d5KP+DNv0ycYWNQam3Sq8EJmLty71KnTXq+hitV6e+YHEzk8eoIdGALTcvKgyhcRXzPIIeKqSfPeN6zd3jHQsKt9/8FFAOfhNHdBGMNDulHRwpPG3thtcH/RWcr599sIAeTEy1DG5acFW0rtLJYM4hXCvuy0eN2JrUEAzBxWu9+iAXKKnWNFZhlafZEfUyMFyON6cbrMwt0TqFSnB1FQcDu5X/H+mGlySTz0bmxedxv7mwmQ3t+xc5VF0RMmzp3mvs3pdsD4g7qm7/hyzYtgoso1OjM2PekqLIY8Hn/0kR0yRlXZm3Ko5ODY0KKFHWb+xTwmDYjIjppsgE9IrrhSRORLcAhLPZzYCOK4Eq2/wYh9kDGU7GV2MxbUoX9a4jRw== ed.barberis+975944588697@cloud9.amazon.com"

# 'grep' to see if the aws cloud9 public key is already present, if not, append to the file.
grep -qF "${aws_cloud9_key_name}" ${user_authorized_keys_file} || echo "${aws_cloud9_public_key}" >> ${user_authorized_keys_file}
chmod 600 ${user_authorized_keys_file}

# delete public key inserted by packer during the ami build.
sed -i -e "/packer/d" ${user_authorized_keys_file}

# configure the hostname of the aws ec2 instance. --------------------------------------------------
# export environment variables.
export aws_ec2_hostname
export aws_ec2_domain

# set the hostname.
./config_al2_system_hostname.sh
