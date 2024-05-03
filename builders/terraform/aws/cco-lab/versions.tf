# Terraform ----------------------------------------------------------------------------------------
terraform {
  required_version = ">= 1.8.2"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.48"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.29"
    }

    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.13"
    }

    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.14"
    }

    null = {
      source  = "hashicorp/null"
      version = ">= 3.2"
    }

    random = {
      source  = "hashicorp/random"
      version = ">= 3.6"
    }
  }
}
