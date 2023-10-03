# Terraform ----------------------------------------------------------------------------------------
terraform {
  required_version = ">= 1.5.7"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.19"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.23"
    }

    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.11"
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
