# Providers ----------------------------------------------------------------------------------------
provider "aws" {
  region = var.aws_region
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.this.token
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.this.token
  }
}

provider "kubectl" {
  apply_retry_count      = 10
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  load_config_file       = false
  token                  = data.aws_eks_cluster_auth.this.token
}

# Locals -------------------------------------------------------------------------------------------
locals {
  # format current date for convenience.
  current_date = formatdate("YYYY-MM-DD", timestamp())

  # format random string for uniqueness.
  unique_string = lower(random_string.suffix.result)

  # create formatted hostname and resource prefixes with lab number.
  lab_hostname_prefix = var.lab_number > 0 ? format("%s-%02d", var.aws_ec2_vm_hostname_prefix, var.lab_number) : var.aws_ec2_vm_hostname_prefix
  lab_resource_prefix = var.lab_number > 0 ? format("%s-%02d", var.resource_name_prefix, var.lab_number) : var.resource_name_prefix

  # create vm ssh ingress cidr block list without duplicates.
  vm_ssh_ingress_cidr_blocks = join(",", distinct(tolist([var.aws_ssh_ingress_cidr_blocks, var.cisco_ssh_ingress_cidr_blocks, var.aws_cloud9_ssh_ingress_cidr_blocks])))

  # NOTE: the eks remote ssh ingress security group contains a "0.0.0.0/0" cidr block rule by default.
  #       when adding our custom cidr blocks, we need to strip off "0.0.0.0/0" (if it exists) to
  #       avoid creating a duplicate rule.
  ssh_ingress_cidr_blocks            = sort(toset(split(",", join(",", tolist([var.aws_ssh_ingress_cidr_blocks, var.cisco_ssh_ingress_cidr_blocks, "0.0.0.0/0"])))))
  ssh_ingress_cidr_blocks_length     = length(local.ssh_ingress_cidr_blocks)
  eks_remote_ssh_ingress_cidr_blocks = slice(local.ssh_ingress_cidr_blocks, 1, local.ssh_ingress_cidr_blocks_length)

  # define resource names here to ensure standardized naming conventions.
  vpc_name                  = "${local.lab_resource_prefix}-${local.unique_string}-VPC"
  security_group_name       = "${local.lab_resource_prefix}-${local.unique_string}-Security-Group"
  vm_name                   = "${local.lab_resource_prefix}-${local.unique_string}-VM"
  cluster_name              = "${local.lab_resource_prefix}-${local.unique_string}-EKS"
  node_group_name           = "${local.lab_resource_prefix}-${local.unique_string}-Node-Group"
  ec2_access_role_name      = "${local.lab_resource_prefix}-${local.unique_string}-EC2-Access-Role"
  ec2_access_policy_name    = "${local.lab_resource_prefix}-${local.unique_string}-EC2-Access-Policy"
  ec2_instance_profile_name = "${local.lab_resource_prefix}-${local.unique_string}-EC2-Instance-Profile"

  # define resource tagging here to ensure standardized naming conventions.
  # cco lab tag names for aws resources.
  cco_resource_tags = {
    EnvironmentHome = var.resource_environment_home_tag
    Owner           = var.resource_owner_tag
    Event           = var.resource_event_tag
    Project         = var.resource_project_tag
#   Date            = local.current_date
  }

  # appdynamics tag names for aws resources.
  appd_resource_tags = {
    ResourceOwner         = var.resource_owner_email_tag
    CiscoMailAlias        = var.resource_owner_email_tag
    JIRAProject           = "NA"
    DataClassification    = "Cisco Public"
    JIRACreation          = "NA"
    SecurityReview        = "NA"
    Exception             = "NA"
    Environment           = "NonProd"
    DeploymentEnvironment = "NonProd"
    DataTaxonomy          = "Cisco Operations Data"
    CreatedBy             = data.aws_caller_identity.current.arn
    IntendedPublic        = "True"
    ContainsPII           = "False"
    Service               = "CCOLab"
    ApplicationName       = var.resource_project_tag
    CostCenter            = var.resource_cost_center_tag
  }

  # if this environment is for appdynamics, merge in 'appd_resource_tags'; otherwise, use 'cco_resource_tags'.
  resource_tags = substr(var.resource_name_prefix, 0, 4) == "CCO" ? merge(local.cco_resource_tags, local.appd_resource_tags) : local.cco_resource_tags
}

# Data Sources -------------------------------------------------------------------------------------
# find the user currently in use by aws.
data "aws_caller_identity" "current" {
}

# availability zones to use in our solution.
data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ami" "cco_lab_ami" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = [var.aws_ec2_source_ami_filter]
  }
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_name
}

data "aws_eks_cluster_auth" "this" {
  name = module.eks.cluster_name
}

data "aws_security_group" "eks_remote" {
  vpc_id = module.vpc.vpc_id

  filter {
    name   = "tag:eks"
    values = toset([trimprefix("${module.eks.eks_managed_node_groups.managed.node_group_id}", "${module.eks.cluster_name}:")])
  }
}

# Modules ------------------------------------------------------------------------------------------
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = ">= 5.9"

  name = local.vpc_name
  cidr = var.aws_vpc_cidr_block

  azs             = data.aws_availability_zones.available.names
  public_subnets  = var.aws_vpc_public_subnets
  private_subnets = var.aws_vpc_private_subnets

  enable_nat_gateway         = true
  single_nat_gateway         = true
  enable_dns_hostnames       = true
  manage_default_network_acl = false
  map_public_ip_on_launch    = true

  tags = local.resource_tags

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = "1"
  }
}

module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = ">= 5.1"

  name        = local.security_group_name
  description = "Security group for LPAD VM EC2 instance"
  vpc_id      = module.vpc.vpc_id

  tags = local.resource_tags

  ingress_cidr_blocks               = ["0.0.0.0/0"]
  ingress_rules                     = ["http-80-tcp", "http-8080-tcp", "https-443-tcp", "all-icmp"]
  egress_rules                      = ["all-all"]
  ingress_with_self                 = [{rule = "all-all"}]
  computed_ingress_with_cidr_blocks = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "Allow SSH access."
      cidr_blocks = local.vm_ssh_ingress_cidr_blocks
    }
  ]
  number_of_computed_ingress_with_cidr_blocks = 1
}

module "vm" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = ">= 5.6"

  name                 = local.vm_name
  ami                  = data.aws_ami.cco_lab_ami.id
  instance_type        = var.aws_ec2_instance_type
  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.id
  key_name             = var.aws_ec2_ssh_pub_key_name

  capacity_reservation_specification = {
    capacity_reservation_preference = "none"
#   capacity_reservation_preference = "open"
  }

  tags = local.resource_tags

  subnet_id                   = tolist(module.vpc.public_subnets)[0]
  vpc_security_group_ids      = [module.security_group.security_group_id]
  associate_public_ip_address = true

  user_data_base64 = base64encode(templatefile("${path.module}/templates/user-data-sh.tmpl", {
    aws_ec2_user_name      = var.aws_ec2_user_name
    aws_ec2_hostname       = "${local.lab_hostname_prefix}-vm"
    aws_ec2_domain         = var.aws_ec2_domain
    aws_region_name        = var.aws_region
    use_aws_ec2_num_suffix = "true"
    aws_eks_cluster_name   = local.cluster_name
    cco_k8s_apm_name       = lower(local.cluster_name)
    cco_lab_id             = lower(trimsuffix(local.cluster_name, "-EKS"))
    lab_number             = var.lab_number
  }))
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = ">= 20.19.0"

  cluster_name    = local.cluster_name
  cluster_version = var.aws_eks_kubernetes_version
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.public_subnets

  cluster_endpoint_private_access      = var.aws_eks_endpoint_private_access
  cluster_endpoint_public_access       = var.aws_eks_endpoint_public_access
  cluster_endpoint_public_access_cidrs = var.aws_eks_endpoint_public_access_cidrs
  cluster_enabled_log_types            = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  tags = local.resource_tags

  # eks managed node groups.
  eks_managed_node_groups = {
    managed = {
#     node_group_name = local.node_group_name
      instance_types  = var.aws_eks_instance_type
      capacity_type   = "ON_DEMAND"
      ami_type        = "AL2_x86_64"
#     subnet_type     = "public"
      subnet_ids      = module.vpc.public_subnets

      # scaling configuration.
      desired_size = var.aws_eks_desired_node_count
      min_size     = var.aws_eks_min_node_count
      max_size     = var.aws_eks_max_node_count

      labels = {
        GithubRepo = "terraform-aws-eks"
        GithubOrg  = "terraform-aws-modules"
      }

      additional_tags = local.resource_tags

      # use default launch template to adjust disk size and allow remote access to worker nodes.
      use_custom_launch_template = false
      disk_size                  = var.aws_eks_instance_disk_size

      remote_access = {
        ec2_ssh_key               = var.lab_ssh_pub_key_name
        source_security_group_ids = null
#       source_security_group_ids = [data.aws_security_group.eks_remote.id]
      }
    }
  }

  authentication_mode = "API"

  enable_cluster_creator_admin_permissions = true

  access_entries = {
    # allow the ec2 access role to administer the cluster.
    role-access = {
      kubernetes_groups = []
      principal_arn     = aws_iam_role.ec2_access_role.arn

      policy_associations = {
        single = {
          policy_arn   = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }
}

# Resources ----------------------------------------------------------------------------------------
resource "random_string" "suffix" {
  length  = 5
  special = false
}

resource "aws_iam_role" "ec2_access_role" {
  name               = local.ec2_access_role_name
  assume_role_policy = file("${path.module}/policies/ec2-assume-role-policy.json")

  tags = local.resource_tags
}

resource "aws_iam_role_policy" "ec2_access_policy" {
  name   = local.ec2_access_policy_name
  role   = aws_iam_role.ec2_access_role.id
  policy = templatefile("${path.module}/policies/ec2-access-policy-template.json", {
    aws_region_name   = var.aws_region
    aws_account_id    = data.aws_caller_identity.current.account_id
    aws_ec2_user_name = var.aws_ec2_user_name
  })
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = local.ec2_instance_profile_name
  role = aws_iam_role.ec2_access_role.name
}

resource "aws_security_group_rule" "eks_remote_ssh_ingress" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  description       = "Allow SSH access."
  cidr_blocks       = local.eks_remote_ssh_ingress_cidr_blocks
  security_group_id = data.aws_security_group.eks_remote.id
}

resource "aws_security_group_rule" "eks_remote_ssh_ingress_for_vm" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  description              = "Allow SSH access from the LPAD VM security group."
  source_security_group_id = module.security_group.security_group_id
  security_group_id        = data.aws_security_group.eks_remote.id
}

resource "aws_security_group_rule" "eks_remote_icmp_ingress" {
  type              = "ingress"
  from_port         = -1
  to_port           = -1
  protocol          = "icmp"
  description       = "Allow ping traffic to EKS cluster."
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = data.aws_security_group.eks_remote.id
}

resource "aws_security_group_rule" "eks_worker_icmp_ingress" {
  type              = "ingress"
  from_port         = -1
  to_port           = -1
  protocol          = "icmp"
  description       = "Allow ping traffic to EKS worker nodes."
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.eks.node_security_group_id
}

resource "aws_security_group_rule" "eks_worker_all_ingress" {
  type                     = "ingress"
  from_port                = -1
  to_port                  = -1
  protocol                 = "all"
  description              = "Allow all traffic from the LPAD VM Security Group."
  source_security_group_id = module.security_group.security_group_id
  security_group_id        = module.eks.node_security_group_id
}

resource "null_resource" "kubectl_trigger" {
  # fire the trigger when the eks cluster requires re-provisioning.
  triggers = {
    eks_cluster_name = module.eks.cluster_name
  }

  # execute the following 'local-exec' provisioners each time the trigger is invoked.
  # run aws cli to retrieve the kubernetes config when the eks cluster is ready.
  provisioner "local-exec" {
    working_dir = "."
    command     = "aws eks --region ${var.aws_region} update-kubeconfig --name ${local.cluster_name}"
  }
}

resource "null_resource" "ansible_trigger" {
  # fire the ansible trigger when the ec2 vm instance requires re-provisioning.
  triggers = {
    ec2_instance_ids = module.vm.id
  }

  # execute the following 'local-exec' provisioners each time the trigger is invoked.
  # generate the ansible aws hosts inventory using 'cat' and Heredoc.
  provisioner "local-exec" {
    working_dir = "../../../../provisioners/ansible/cco-lab"
    command     = <<EOD
cat <<EOF > aws_hosts.inventory
[cco_lab_vm]
${module.vm.public_dns}
EOF
EOD
  }
}
