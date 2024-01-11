#!/bin/bash
#---------------------------------------------------------------------------------------------------
# Update AWS CCO Cloud9 environment memberships.
#
# AWS Cloud9 is a cloud-based integrated development environment (IDE) that lets you write, run,
# and debug your code with just a browser. It includes a code editor, debugger, and terminal.
# Cloud9 comes prepackaged with essential tools for popular programming languages, including
# JavaScript, Python, PHP, and more, so you don’t need to install files or configure your
# development machine to start new projects.
#
# A shared environment membership is an AWS Cloud9 development environment that multiple users
# have been invited to participate in.
#
# For the CCO labs, this script automates the addition of the CCO lab user as well as other AWS
# account 'admin' users in order to facilitate delivery of the CCO lab enablement workshops.
#
# For more details, please visit:
#   https://aws.amazon.com/cloud9/
#   https://docs.aws.amazon.com/cloud9/latest/user-guide/share-environment.html
#
# NOTE: All inputs are defined by external environment variables.
#       Script should be run with installed user privilege (i.e. 'non-root' user).
#       User should have pre-configured AWS CLI and 'jq' command-line JSON processor.
#---------------------------------------------------------------------------------------------------

# set default values for input environment variables if not set. -----------------------------------
# [OPTIONAL] update cloud9 memberships parameters [w/ defaults].
aws_region_name="${aws_region_name:-us-east-2}"
cco_name_prefix="${cco_name_prefix:-CCO-Lab}"

# retrieve list of all eks clusters. ---------------------------------------------------------------
echo "Retrieving list of all EKS clusters in AWS '${aws_region_name}' region..."
all_eks_cluster_names=$(aws eks --region ${aws_region_name} list-clusters --query "clusters[*]" | jq -r '.[]')
echo ""

# check if any EKS clusters were found.
if [ -z "$all_eks_cluster_names" ]; then
  echo "Error: No EKS clusters found in AWS '${aws_region_name}' region."
  exit 1
fi

# convert list to array of all eks clusters.
all_eks_cluster_names_array=( $all_eks_cluster_names )

# print list of all eks cluster names.
echo "All EKS clusters:"
for eks_cluster_name in "${all_eks_cluster_names_array[@]}"; do
  echo $eks_cluster_name
done
echo ""

# create new array with 'filtered' cco eks cluster names.
echo "Filtering list for '${cco_name_prefix}' EKS clusters in AWS '${aws_region_name}' region..."
cco_eks_cluster_names_array=()
for eks_cluster_name in "${all_eks_cluster_names_array[@]}"; do
  if [[ "$eks_cluster_name" == *"$cco_name_prefix"* ]]; then
    cco_eks_cluster_names_array+=( $eks_cluster_name )
  fi
done
echo ""

# print list of cco eks cluster names.
echo "CCO EKS clusters:"
for eks_cluster_name in "${cco_eks_cluster_names_array[@]}"; do
  echo $eks_cluster_name
done
echo ""

#cco_ec2_instances_metadata=$(aws ec2 --region ${aws_region_name} describe-instances --filters "Name=tag-key,Values=eks:cluster-name" "Name=tag-value,Values=*${cco_name_prefix}*EKS" "Name=instance-state-name,Values=running" --query "Reservations[*].Instances[*].{eksClusterName:Tags[?Key=='eks:cluster-name']|[0].Value,InstanceId:InstanceId}" | jq '[.[][]] | sort_by(.eksClusterName)')
aws ec2 --region ${aws_region_name} describe-instances --filters "Name=tag-key,Values=eks:cluster-name" "Name=tag-value,Values=*${cco_name_prefix}*EKS" "Name=instance-state-name,Values=running" --query "Reservations[*].Instances[*].{eksClusterName:Tags[?Key=='eks:cluster-name']|[0].Value,InstanceId:InstanceId}" | jq '[.[][]] | sort_by(.eksClusterName)'

#cco_ec2_instances_metadata=$(
#  aws ec2
#    --region ${aws_region_name}
#    describe-instances
#    --filters "Name=tag-key,Values=eks:cluster-name" "Name=tag-value,Values=*${cco_name_prefix}*EKS" "Name=instance-state-name,Values=running"
#    --query "Reservations[*].Instances[*].{eksClusterName:Tags[?Key=='eks:cluster-name']|[0].Value,InstanceId:InstanceId}" |
#  jq '[.[][]] |
#    sort_by(.eksClusterName)')

exit


# retrieve metadata for running cco ec2 instances. -------------------------------------------------
echo "Retrieving metadata for running '${cco_name_prefix}' EC2 instances in '${aws_region_name}'..."
#cco_ec2_instances_metadata=$(aws ec2 --region ${aws_region_name} describe-instances --filters "Name=tag-key,Values=Name" "Name=tag-value,Values=*${cco_name_prefix}*VM" "Name=instance-state-name,Values=running" --query "Reservations[*].Instances[*].{Name:Tags[?Key=='Name']|[0].Value,InstanceId:InstanceId}" | jq '[.[][]] | sort_by(.Name)')
cco_ec2_instances_metadata=$(
  aws ec2
    --region ${aws_region_name}
    describe-instances
    --filters "Name=tag-key,Values=Name" "Name=tag-value,Values=*${cco_name_prefix}*VM" "Name=instance-state-name,Values=running"
    --query "Reservations[*].Instances[*].{Name:Tags[?Key=='Name']|[0].Value,InstanceId:InstanceId}" |
  jq '[.[][]] |
    sort_by(.Name)')

#cco_ec2_tags_metadata=$(aws ec2 --region ${aws_region_name} describe-tags --filters "Name=resource-id, Values=${cco_ec2_instances_ids_array[$jj]}" | jq '. | del(.Tags[] | select(.Key == "Name")) | del(.Tags[].ResourceId, .Tags[].ResourceType)')
cco_ec2_tags_metadata=$(
  aws ec2
    --region ${aws_region_name}
    describe-tags
    --filters "Name=resource-id, Values=${cco_ec2_instances_ids_array[$jj]}" |
  jq '. |
    del(.Tags[] |
    select(.Key == "Name")) |
    del(.Tags[].ResourceId, .Tags[].ResourceType)')

# retrieve metadata for cco eks clusters. ----------------------------------------------------------
#echo "Retrieving metadata for '${cco_name_prefix}' EKS clusters in '${aws_region_name}'..."
#cco_eks_clusters_metadata=$(aws eks --region ${aws_region_name} describe-cluster --name $all_cloud9_envs --query "environments[*]" | jq -r --arg CCO_NAME_PREFIX "${cco_name_prefix}" '[.[] | select(.name | contains($CCO_NAME_PREFIX)) | {name: .name, id: .id}] | sort_by(.name)')

#aws eks --region us-east-2 describe-cluster --name AppD-CCO-Lab-04-jioqe-EKS | jq '.'

#aws sts get-caller-identity
#aws eks --region us-east-2 describe-nodegroup --generate-cli-skeleton
#aws eks --region us-east-2 list-clusters | jq '.'
#aws eks --region us-east-2 describe-cluster --name AppD-CCO-Lab-04-jioqe-EKS | jq '.'
#aws eks --region us-east-2 list-nodegroups --cluster-name AppD-CCO-Lab-04-jioqe-EKS | jq '.'
#aws eks --region us-east-2 describe-nodegroup --cluster-name AppD-CCO-Lab-04-jioqe-EKS --nodegroup-name AppD-CCO-Lab-04-jioqe-EKS-node-group20220411194255487000000010 | jq '.'
#aws autoscaling --region us-east-2 describe-auto-scaling-groups --auto-scaling-group-names eks-AppD-CCO-Lab-04-jioqe-EKS-node-group20220411194255487000000010-04c00d13-461c-c7b9-6090-777b0e0c2171 | jq '.'



# retrieve metadata for cco cloud9 environments. ---------------------------------------------------
echo "Retrieving metadata for '${cco_name_prefix}' Cloud9 environments in '${aws_region_name}'..."
cco_cloud9_envs_metadata=$(aws cloud9 --region ${aws_region_name} describe-environments --environment-ids $all_cloud9_envs --query "environments[*]" | jq -r --arg CCO_NAME_PREFIX "${cco_name_prefix}" '[.[] | select(.name | contains($CCO_NAME_PREFIX)) | {name: .name, id: .id}] | sort_by(.name)')

# check if any cco cloud9 environments were found.
if [ -z "$(echo $cco_cloud9_envs_metadata | jq '. | select(length > 0)')" ]; then
  echo "Error: No '${cco_name_prefix}' Cloud9 environments found in AWS '${aws_region_name}' region."
  exit 1
fi

# print list of cco cloud9 environment metadata.
echo $cco_cloud9_envs_metadata | jq '. | select(length > 0)'
echo ""

# create array of names for cco cloud9 environments.
cco_cloud9_env_names_array=()
cco_cloud9_env_names_array+=( $(echo $cco_cloud9_envs_metadata | jq -r '.[] | .name') )

#for cco_cloud9_env_name in "${cco_cloud9_env_names_array[@]}"; do
#  echo $cco_cloud9_env_name
#done
#echo ""

# create array of ids for cco cloud9 environments.
cco_cloud9_env_ids_array=()
cco_cloud9_env_ids_array+=( $(echo $cco_cloud9_envs_metadata | jq -r '.[] | .id') )

#for cco_cloud9_env_id in "${cco_cloud9_env_ids_array[@]}"; do
#  echo $cco_cloud9_env_id
#done
#echo ""

# retrieve current aws account id. -----------------------------------------------------------------
echo "Retrieving current AWS Account ID..."
aws_account_id=$(aws sts get-caller-identity --query "Account" --output text)

# check if aws account id was found.
if [ -z "$aws_account_id" ]; then
  echo "Error: AWS Account ID not found."
  exit 1
fi

# print aws account id.
echo "AWS Account ID: '${aws_account_id}'"
echo ""

# create array of user arns to add to cloud9 environment memberships. ------------------------------
# NOTE: cloud9 supports a maximum of 7 shared memberships plus the owner.
echo "Creating array of User ARNs to add to Cloud9 memberships..."
cco_cloud9_user_share_array=()

# create user arns array for appd cisco runon aws account.
if [ "${aws_account_id}" == "395719258032" ]; then
  cco_cloud9_user_share_array+=( "arn:aws:iam::395719258032:user/cco-lab-user" )
  cco_cloud9_user_share_array+=( "arn:aws:iam::395719258032:user/ed.barberis" )
  cco_cloud9_user_share_array+=( "arn:aws:iam::395719258032:user/james.schneider" )
  cco_cloud9_user_share_array+=( "arn:aws:iam::395719258032:user/wayne.brown" )
# create user arns array for appd original aws account.
elif [ "${aws_account_id}" == "975944588697" ]; then
  cco_cloud9_user_share_array+=( "arn:aws:iam::975944588697:user/cco-lab-user" )
  cco_cloud9_user_share_array+=( "arn:aws:sts::975944588697:assumed-role/AWSReservedSSO_appd-aws-975944588697-dev_35531c6d12fd4c96/ed.barberis@appdynamics.com" )
  cco_cloud9_user_share_array+=( "arn:aws:sts::975944588697:assumed-role/AWSReservedSSO_appd-aws-975944588697-dev_35531c6d12fd4c96/james.schneider@appdynamics.com" )
  cco_cloud9_user_share_array+=( "arn:aws:sts::975944588697:assumed-role/AWSReservedSSO_appd-aws-975944588697-dev_35531c6d12fd4c96/ramiro.nagles@appdynamics.com" )
  cco_cloud9_user_share_array+=( "arn:aws:sts::975944588697:assumed-role/AWSReservedSSO_appd-aws-975944588697-dev_35531c6d12fd4c96/wayne.brown@appdynamics.com" )
# create user arns array for apo cisco runon aws account.
elif [ "${aws_account_id}" == "496972728175" ]; then
  cco_cloud9_user_share_array+=( "arn:aws:iam::496972728175:user/jeff.teeter" )
  cco_cloud9_user_share_array+=( "arn:aws:iam::496972728175:user/justin.weems" )
else
  echo "Error: aws_account_id: IAM users undefined for AWS Account: '${aws_account_id}'."
  exit 1
fi

# print user arns array.
echo "User ARNs:"
for cco_cloud9_user_arn in "${cco_cloud9_user_share_array[@]}"; do
  echo $cco_cloud9_user_arn
done
echo ""

# check to make sure we don't have more than 7 users in the array.
if [ "${#cco_cloud9_user_share_array[@]}" -gt 7 ]; then
  echo "Error: You cannot invite more than 7 members to your environment (8 total-including the owner)."
  exit 1
fi

# add user arns to cloud9 environment membership. --------------------------------------------------
# loop for each user arn,
for cco_cloud9_user_arn in "${cco_cloud9_user_share_array[@]}"; do
  # initialize array index.
  ii=0

  # loop for each cco cloud9 environment arn,
  for cco_cloud9_env_id in "${cco_cloud9_env_ids_array[@]}"; do
    # retrieve cco cloud9 metadata filtered by user arn.
    echo "Checking for user: '${cco_cloud9_user_arn}' in Cloud9 environment: '${cco_cloud9_env_names_array[$ii]}..."
    cco_cloud9_member_metadata=$(aws cloud9 --region ${aws_region_name} describe-environment-memberships --environment-id $cco_cloud9_env_id --query "memberships[*]" | jq -r --arg USER_ARN "${cco_cloud9_user_arn}" '[.[] | select(.userArn | contains($USER_ARN)) | {userArn: .userArn, permissions: .permissions}] | sort_by(.name)')

    # is user arn is already a member of the cloud9 environment?
    if [ -z "$(echo $cco_cloud9_member_metadata | jq '. | select(length > 0)')" ]; then
      echo "Adding user: '${cco_cloud9_user_arn}' to Cloud9 environment: '${cco_cloud9_env_names_array[$ii]}..."
      aws cloud9 --region ${aws_region_name} create-environment-membership --environment-id $cco_cloud9_env_id --user-arn $cco_cloud9_user_arn --permissions read-write | jq '.'
      echo ""
    fi

    # increment array index.
    ii=$(($ii + 1))
  done
done
echo ""

# print completion message. ------------------------------------------------------------------------
echo "Update '${cco_name_prefix}' Cloud9 environments in '${aws_region_name}' operation complete."
