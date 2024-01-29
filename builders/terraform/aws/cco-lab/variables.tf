# Variables ----------------------------------------------------------------------------------------
variable "aws_region" {
  description = "AWS region."
  type        = string
  default     = "us-east-2"
}

variable "aws_vpc_cidr_block" {
  description = "The CIDR block for the VPC."
  type        = string
  default     = "172.16.0.0/16"
}

variable "aws_vpc_public_subnets" {
  description = "A list of public subnets inside the VPC."
  type        = list(string)
  default     = ["172.16.0.0/24", "172.16.1.0/24", "172.16.2.0/24"]
}

variable "aws_vpc_private_subnets" {
  description = "A list of private subnets inside the VPC."
  type        = list(string)
  default     = ["172.16.3.0/24"]
}

variable "aws_ssh_ingress_cidr_blocks" {
  description = "The ingress CIDR blocks for inbound ssh traffic external to AWS."
  type        = string
  default     = "0.0.0.0/0"
}

variable "cisco_ssh_ingress_cidr_blocks" {
  description = "The ingress CIDR blocks for inbound ssh traffic from Cisco networks."
  type        = string
  default     = "128.107.241.0/24,72.163.220.53/32,209.234.175.138/32,173.38.208.173/32,173.38.220.54/32,72.163.220.0/24,173.39.121.0/24"
}

variable "aws_cloud9_ssh_ingress_cidr_blocks" {
  description = "The ingress CIDR blocks for inbound ssh traffic from AWS Cloud9 System Manager and EC2 Instance Connect."
  type        = string
  default     = "35.172.155.192/27,35.172.155.96/27,18.206.107.24/29,18.188.9.0/27,18.188.9.32/27,3.16.146.0/29,13.52.232.224/27,18.144.158.0/27,13.52.6.112/29,34.217.141.224/27,34.218.119.32/27,18.237.140.160/29,18.184.138.224/27,18.184.203.128/27,3.120.181.40/29,3.10.127.32/27,3.10.201.64/27,3.8.37.24/29,13.250.186.128/27,13.250.186.160/27,3.0.5.32/29"
}

variable "aws_ec2_vm_hostname_prefix" {
  description = "AWS EC2 VM hostname prefix."
  type        = string
  default     = "cco-lab"
}

variable "aws_ec2_domain" {
  description = "AWS EC2 domain name."
  type        = string
  default     = "localdomain"
}

variable "aws_ec2_user_name" {
  description = "AWS EC2 user name."
  type        = string
  default     = "ec2-user"
}

variable "aws_ec2_ssh_pub_key_name" {
  description = "AWS EC2 SSH public key for Lab VMs."
  type        = string
  default     = "Channel-CCO-Workshop"
}

variable "aws_ec2_source_ami_filter" {
  description = "AWS EC2 source AMI disk image filter."
  type        = string
  default     = "CCO-LPAD-AL2-AMI-*"
}

variable "aws_ec2_instance_type" {
  description = "AWS EC2 instance type."
  type        = string
# default     = "t3.micro"
  default     = "t3.large"
}

variable "lab_number" {
  description = "Lab number for incrementally naming resources."
  type        = number
  default     = 1
}

# NOTE: If set to 'false', ensure to have a proper private access with 'cluster_endpoint_private_access = true'.
variable "aws_eks_endpoint_private_access" {
  description = "Indicates whether or not the Amazon EKS private API server endpoint is enabled."
  type        = bool
  default     = false
}

# NOTE: If set to 'false', ensure to have a proper private access with 'cluster_endpoint_private_access = true'.
variable "aws_eks_endpoint_public_access" {
  description = "Indicates whether or not the Amazon EKS public API server endpoint is enabled."
  type        = bool
  default     = true
}

variable "aws_eks_endpoint_public_access_cidrs" {
  description = "List of CIDR blocks which can access the EKS public API server endpoint."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "aws_eks_desired_node_count" {
  description = "Desired number of EKS worker nodes."
  type        = number
  default     = 2
}

variable "aws_eks_min_node_count" {
  description = "Minimum number of EKS worker nodes."
  type        = number
  default     = 1
}

variable "aws_eks_max_node_count" {
  description = "Maximum number of EKS worker nodes."
  type        = number
  default     = 3
}

variable "aws_eks_instance_type" {
  description = "AWS EKS Node Group instance type."
  type        = list(string)
# default     = ["t3a.large"]
  default     = ["t3a.xlarge"]
}

variable "aws_eks_instance_disk_size" {
  description = "Disk size for AWS EKS Node instances."
  type        = number
  default     = 80
}

# valid aws eks versions are: 1.24, 1.25, 1.26, 1.27, 1.28, and 1.29.
variable "aws_eks_kubernetes_version" {
  description = "Kubernetes version to use for the EKS cluster."
  type        = string
  default     = "1.28"
}

variable "lab_ssh_pub_key_name" {
  description = "Name of SSH public key for EKS worker nodes."
  type        = string
  default     = "Channel-CCO-Workshop"
}

variable "resource_name_prefix" {
  description = "Resource name prefix."
  type        = string
  default     = "CCO-Lab"
}

variable "resource_environment_home_tag" {
  description = "Resource environment home tag."
  type        = string
  default     = "Channel CCO Lab"
}

variable "resource_owner_tag" {
  description = "Resource owner tag."
  type        = string
  default     = "Cisco AppDynamics Cloud Channel Sales Teams"
}

variable "resource_event_tag" {
  description = "Resource event tag."
  type        = string
  default     = "CCO Lab Demo"
}

variable "resource_project_tag" {
  description = "Resource project tag."
  type        = string
  default     = "Channel CCO Workshop"
}

variable "resource_owner_email_tag" {
  description = "Resource owner email tag."
  type        = string
  default     = "ed.barberis@appdynamics.com"
}

variable "resource_cost_center_tag" {
  description = "Resource cost center tag."
  type        = string
  default     = "020430801"
}

variable "map_roles" {
  description = "Additional IAM roles to add to the aws-auth configmap."

  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))

  default = [
    {
      rolearn  = "arn:aws:iam::66666666666:role/role1"
      username = "role1"
      groups   = ["system:masters"]
    }
  ]
}

variable "map_users" {
  description = "Additional IAM users to add to the aws-auth configmap."

  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))

  default = [
    {
      userarn  = "arn:aws:iam::66666666666:user/user1"
      username = "user1"
      groups   = ["system:masters"]
    }
  ]
}
