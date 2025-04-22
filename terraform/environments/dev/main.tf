provider "aws" {
  region = "eu-west-1"
}

terraform {
  required_version = ">= 1.0"

  backend "s3" {
    bucket = "revolut-terraform-state"
    key    = "dev/terraform.tfstate"
    region = "eu-west-1"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
  }
}

module "vpc" {
  source = "../../modules/vpc"

  environment = "dev"
  vpc_cidr    = "10.0.0.0/16"
}

module "eks" {
  source = "../../modules/eks"

  environment  = "dev"
  cluster_name = "revolut-cluster"
  vpc_id       = module.vpc.vpc_id
  subnet_ids   = module.vpc.private_subnet_ids
}

module "monitoring" {
  source = "../../modules/monitoring"

  environment     = "dev"
  eks_cluster_id  = module.eks.cluster_id
  namespace       = "monitoring"
} 