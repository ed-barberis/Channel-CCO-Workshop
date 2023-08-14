# Terraform ----------------------------------------------------------------------------------------
terraform {
  required_version = ">= 1.5.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.12"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.22"
    }

    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.10"
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
      version = ">= 3.5"
    }
  }
}
