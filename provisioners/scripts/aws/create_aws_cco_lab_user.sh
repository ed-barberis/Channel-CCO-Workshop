#!/bin/bash
#---------------------------------------------------------------------------------------------------
# Create CCO Lab User with associated Group and Policies.
#
# An AWS Identity and Access Management (IAM) user is an entity that you create in AWS to represent
# the person or application that uses it to interact with AWS. A user in AWS consists of a name and
# credentials.
#
# To simplify workshop provisioning, all lab participants will make use of the CCO Lab User
# assigned to them. Each participant will login to the AWS Console in order to access their Cloud9
# IDE.
# 
# For more details, please visit:
#   https://docs.aws.amazon.com/IAM/latest/UserGuide/id_users.html
#   https://docs.aws.amazon.com/IAM/latest/UserGuide/id_groups.html
#   https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies.html
#
# NOTE: All inputs are defined by external environment variables.
#       Script should be run with installed user privilege (i.e. 'non-root' user).
#       User should have pre-configured AWS CLI.
#---------------------------------------------------------------------------------------------------

# set default values for input environment variables if not set. -----------------------------------
# [OPTIONAL] aws create user install parameters [w/ defaults].
aws_user_name="${aws_user_name:-cco-lab-user}"
aws_user_password="${aws_user_password:-}"
aws_group_name="${aws_group_name:-cco-lab-group}"
local_devops_home="${local_devops_home:-${HOME}/Channel-CCO-Workshop}"

# define usage function. ---------------------------------------------------------------------------
usage() {
  cat <<EOF
Usage:
  NOTE: All inputs are defined by external environment variables.
        Script should be run with installed user privilege (i.e. 'non-root' user).
        User should have pre-configured AWS CLI.

  Description of Environment Variables:
    [ubuntu]$ export aws_user_name="cco-lab-user"                       # [optional] cco lab user name.
    [ubuntu]$ export aws_user_password="<custom_password_here>"         # [optional] cco lab user password.
    [ubuntu]$ export aws_group_name="cco-lab-group"                     # [optional] cco lab group name.
    [ubuntu]$ export local_devops_home="${HOME}/Channel-CCO-Workshop"   # [optional] local devops home environment variable.

  Example:
    [ubuntu]$ $0
EOF
}

# validate environment variables. ------------------------------------------------------------------
# check if aws user password was set.
if [ -z "$aws_user_password" ]; then
  echo "Error: 'aws_user_password' environment variable not set."
  usage
  exit 1
fi

# check if aws group already exists.
aws_group=$(aws iam list-groups | jq -r --arg AWS_GROUP_NAME "${aws_group_name}" '.Groups[] | select(.GroupName | contains($AWS_GROUP_NAME)) | .GroupName')

if [ ! -z "$aws_group" ]; then
  echo "Error: aws_group_name: ${aws_group_name} already exists."
  usage
  exit 1
fi

# check if aws user already exists.
aws_user=$(aws iam list-users | jq -r --arg AWS_USER_NAME "${aws_user_name}" '.Users[] | select(.UserName | contains($AWS_USER_NAME)) | .UserName')

if [ ! -z "$aws_user" ]; then
  echo "Error: aws_user_name: ${aws_user_name} already exists."
  usage
  exit 1
fi

# create cco lab group and attach group policies. --------------------------------------------------
# create cco lab group.
echo "Creating CCO Lab group in AWS..."
echo "aws iam create-group --group-name ${aws_group_name}"
aws iam create-group --group-name ${aws_group_name}

# attach group policies to cco lab group.
echo "Attaching group policies to CCO Lab group..."
echo "aws iam attach-group-policy --group-name ${aws_group_name} --policy-arn arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
echo "aws iam attach-group-policy --group-name ${aws_group_name} --policy-arn arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
echo "aws iam attach-group-policy --group-name ${aws_group_name} --policy-arn arn:aws:iam::aws:policy/AWSCloud9EnvironmentMember"

aws iam attach-group-policy --group-name ${aws_group_name} --policy-arn arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess
aws iam attach-group-policy --group-name ${aws_group_name} --policy-arn arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess
aws iam attach-group-policy --group-name ${aws_group_name} --policy-arn arn:aws:iam::aws:policy/AWSCloud9EnvironmentMember

# create cco lab user and add to cco lab group. ----------------------------------------------------
# create cco lab user.
echo "Creating CCO Lab user in AWS..."
echo "aws iam create-user --user-name ${aws_user_name}-${cco_lab_number}"
aws iam create-user --user-name ${aws_user_name}

echo "aws iam create-login-profile --user-name ${aws_user_name}-${cco_lab_number} --password \"${aws_user_password}\" --no-password-reset-required"
aws iam create-login-profile --user-name ${aws_user_name} --password "${aws_user_password}" --no-password-reset-required

# add cco lab user to cco lab group.
echo "Adding CCO Lab user to CCO Lab group..."
echo "aws iam add-user-to-group --group-name ${aws_group_name} --user-name ${aws_user_name}-${cco_lab_number}"
aws iam add-user-to-group --group-name ${aws_group_name} --user-name ${aws_user_name}

# print completion message.
echo "CCO Lab User creation complete."
