#!/bin/sh -eux
# appdynamics cwom cloud-init script to initialize aws ec2 instance launched from ami.

# set default values for input environment variables if not set. -----------------------------------
# [OPTIONAL] aws user and host name config parameters [w/ defaults].
user_name="${user_name:-centos}"
aws_ec2_hostname="${aws_ec2_hostname:-cwom}"
aws_ec2_domain="${aws_ec2_domain:-localdomain}"

# configure public keys for specified user. --------------------------------------------------------
user_authorized_keys_file="/home/${user_name}/.ssh/authorized_keys"
user_key_name="Channel-CCO-Workshop"
user_public_key="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDFasc821rZcs1gXEdjwtOLBgV6BUwkGRKXJHIMXbld6Gcy0yo2iHQm5eimO7GYzkHsB1XL4x0uxqXtrSQm2QY+taXWfjH5MsAY2pnwb3jPYxeBWclLyLnX5IAXnDwC5PngnLMKxRHJL3jpbmYov7ViKtpiNnS3ExMSxbuMITf2bfza2Ws9VKNBY6n3Tyk96oICPgTIcN1V+fZrMBfSTGpQmcsrMK/poOFKfS61wq9f20pD93/v8hdz6VPP/WwVQKdZBdGxIy7eY+WJl7qv7bDlHgQi/+g/Tt+RUtGwxEoIvjp0B/VQK11emTqv2Jlq+XH/VQC8w0kXEIugro2ukYO9 Channel-CCO-Workshop"

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
