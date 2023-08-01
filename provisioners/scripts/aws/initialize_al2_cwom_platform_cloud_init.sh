#!/bin/sh -eux
# appdynamics cwom cloud-init script to initialize aws ec2 instance launched from ami.

# set default values for input environment variables if not set. -----------------------------------
# [OPTIONAL] aws user and host name config parameters [w/ defaults].
user_name="${user_name:-centos}"
aws_ec2_hostname="${aws_ec2_hostname:-cwom}"
aws_ec2_domain="${aws_ec2_domain:-localdomain}"

# configure public keys for specified user. --------------------------------------------------------
user_authorized_keys_file="/home/${user_name}/.ssh/authorized_keys"
user_key_name="Channel-CNAO-Workshop"
user_public_key="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCkVnb7a69d+MSRG08WdqfvWXEpnT544XzohdZ0sIs5fRLU+pAh48F+BieIqxvCUKIUDXQFP04iQmoo5MKiLH42YVfDmsoidLDejiDS0O5KTn8DS6jA2akeT19xpYweKmRcw4kz+DeBe9dmYmggGQYZx48bSwBrwHcjvJciYTbLyBxmTx/kUIfn4Ub81cfoKq/m5qh/LnyZsXo+ZWj6kGDWsqSpX3I0jysaEsvQDRoRUUe0gSPIe7Y3IfTLsCj0PxzFMDqASeHMMGGoBzMhdWXexiDCUIcToGRKTC6FVfDEZs1kTYKJe7hp0CJtZHMdM7yAhb1JSAURT6ZcOwopxIH7 Channel-CNAO-Workshop"

# 'grep' to see if the user's public key is already present, if not, append to the file.
grep -qF "${user_key_name}" ${user_authorized_keys_file} || echo "${user_public_key}" >> ${user_authorized_keys_file}
chmod 600 ${user_authorized_keys_file}

# delete public key inserted by packer during the ami build.
sed -i -e "/packer/d" ${user_authorized_keys_file}

# configure the hostname of the aws ec2 instance. --------------------------------------------------
# export environment variables.
export aws_ec2_hostname
export aws_ec2_domain

# set the hostname.
./config_al2_system_hostname.sh
