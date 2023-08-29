# ------------------------------------------------------------------------------
# DEPLOY A SPACELIFT STACK WITH TERRAGRUNT
#
# This example shows how to deploy a spacelift stack using terragrunt. This is
# useful if you want to use terragrunt to manage your infrastructure code.
# ------------------------------------------------------------------------------

terraform {
  required_version = "~> 1.5.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    spacelift = {
      source  = "spacelift-io/spacelift"
      version = "~> 1.1.9"
    }
  }
}


# --------------------------------------------------
# CONFIGURE OUR AWS CONNECTION
# --------------------------------------------------

provider "aws" {
  region = var.aws_region
}


# --------------------------------------------------
# CONFIGURE OUR SPACELIFT CONNECTION
# --------------------------------------------------

provider "spacelift" {
  api_key_endpoint = var.api_key_endpoint
  api_key_id       = var.spacelift_key_id
  api_key_secret   = var.spacelift_key_secret
}
