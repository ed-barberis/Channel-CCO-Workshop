#!/bin/sh -eux
# appdynamics lpad cloud-init script to initialize aws ec2 instance launched from ami.

# set default values for input environment variables if not set. -----------------------------------
# [MANDATORY] aws cli config parameters [w/ defaults].
set +x  # temporarily turn command display OFF.
AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID:-}"
AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY:-}"
set -x  # turn command display back ON.

# [OPTIONAL] aws user and host name config parameters [w/ defaults].
user_name="${user_name:-centos}"
aws_ec2_hostname="${aws_ec2_hostname:-lpad}"
aws_ec2_domain="${aws_ec2_domain:-localdomain}"

# [OPTIONAL] aws cli config parameters [w/ defaults].
aws_cli_default_region_name="${aws_cli_default_region_name:-us-east-1}"
aws_cli_default_output_format="${aws_cli_default_output_format:-json}"

# validate environment variables. ------------------------------------------------------------------
set +x    # temporarily turn command display OFF.
if [ -z "$AWS_ACCESS_KEY_ID" ]; then
  echo "Error: 'AWS_ACCESS_KEY_ID' environment variable not set."
  exit 1
fi

if [ -z "$AWS_SECRET_ACCESS_KEY" ]; then
  echo "Error: 'AWS_SECRET_ACCESS_KEY' environment variable not set."
  exit 1
fi
set -x    # turn command display back ON.

if [ -n "$aws_cli_default_output_format" ]; then
  case $aws_cli_default_output_format in
      json|text|table)
        ;;
      *)
        echo "Error: invalid 'aws_cli_default_output_format'."
        exit 1
        ;;
  esac
fi

# configure public keys for specified user. --------------------------------------------------------
user_authorized_keys_file="/home/${user_name}/.ssh/authorized_keys"
user_key_name="Channel-CCO-Workshop"
user_public_key="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDFasc821rZcs1gXEdjwtOLBgV6BUwkGRKXJHIMXbld6Gcy0yo2iHQm5eimO7GYzkHsB1XL4x0uxqXtrSQm2QY+taXWfjH5MsAY2pnwb3jPYxeBWclLyLnX5IAXnDwC5PngnLMKxRHJL3jpbmYov7ViKtpiNnS3ExMSxbuMITf2bfza2Ws9VKNBY6n3Tyk96oICPgTIcN1V+fZrMBfSTGpQmcsrMK/poOFKfS61wq9f20pD93/v8hdz6VPP/WwVQKdZBdGxIy7eY+WJl7qv7bDlHgQi/+g/Tt+RUtGwxEoIvjp0B/VQK11emTqv2Jlq+XH/VQC8w0kXEIugro2ukYO9 Channel-CCO-Workshop"

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

# configure the aws cli client. --------------------------------------------------------------------
# remove current configuration if it exists.
aws_cli_config_dir="/home/${user_name}/.aws"
if [ -d "$aws_cli_config_dir" ]; then
  rm -Rf ${aws_cli_config_dir}
fi

set +x    # temporarily turn command display OFF.
aws_config_cmd=$(printf "aws configure <<< \$\'%s\\\\n%s\\\\n%s\\\\n%s\\\\n\'\n" ${AWS_ACCESS_KEY_ID} ${AWS_SECRET_ACCESS_KEY} ${aws_cli_default_region_name} ${aws_cli_default_output_format})
runuser -c "PATH=/home/${user_name}/.local/bin:${PATH} eval ${aws_config_cmd}" - ${user_name}
set -x    # turn command display back ON.

# verify the aws cli configuration by displaying a list of aws regions in table format.
runuser -c "PATH=/home/${user_name}/.local/bin:${PATH} aws ec2 describe-regions --output table" - ${user_name}
