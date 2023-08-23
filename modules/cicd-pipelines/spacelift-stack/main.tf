# -------------------------------------------------------------------------------------
# CREATE SPACELIFT STACKS FOR (GIT)-FLOW 
# 
# These templates deploys a Spacelift stack that can be used to manage your terraform
# infrastructure using terraform or terragrunt. The module includes the following:
# - Spacelift stack
# - AWS IAM role for Spacelift
# -------------------------------------------------------------------------------------

# -------------------------------------------
# SET TERRAFORM REQUIREMENTS TO RUN MODULE
# -------------------------------------------

terraform {
  required_version = ">= 1.5.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "=> 5.0"
    }
    spacelift = {
      source  = "spacelift-io/spacelift"
      version = "=> 0.1.11"
    }
  }
}

# -------------------------------------------
# CONVIENIENCE VARIABLES
# -------------------------------------------

data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id

  iam_role_name = "${var.stack_name}-role"

  iam_role_arn = "arn:aws:iam::${local.account_id}:role/${local.iam_role_name}"
}


# -------------------------------------------
# CREATE THE SPACELIFT STACK
# -------------------------------------------

resource "spacelift_stack" "this" {

  dynamic "terragrunt" {
    for_each = var.terragrunt_version ? [var.terragrunt_version] : []

    content {
      terraform_version      = var.terraform_version
      terragrunt_version     = var.terragrunt_version
      use_run_all            = var.terragrunt_use_run_all
      use_smart_sanitization = true
    }
  }

  administrative        = var.enable_admin_stack
  autodeploy            = var.autodeploy
  branch                = var.branch
  description           = var.description
  labels                = var.labels
  manage_state          = var.enable_state_management
  name                  = var.stack_name
  project_root          = var.project_root
  protect_from_deletion = true
  repository            = var.repository

  terraform_smart_sanitization = true
  terraform_version            = var.terraform_version

}


# ---------------------------------------------------
# CREATE THE AWS IAM ROLE FOR SPACELIFT INTEGRATION
# ---------------------------------------------------

resource "spacelift_aws_integration" "this" {
  count = var.create_iam_role ? 1 : 0

  name = local.iam_role_name

  # We need to set this manually rather than referencing the role to avoid a circular dependency
  # between the role and the integration.
  role_arn                       = local.iam_role_arn
  generate_credentials_in_worker = false
}

data "spacelift_aws_integration_attachment_external_id" "this" {
  count = var.create_iam_role ? 1 : 0

  integration_id = spacelift_aws_integration.this.id
  stack_id       = spacelift_stack.this.id
  read           = true
  write          = true
}

resource "aws_iam_role" "this" {
  count = var.create_iam_role ? 1 : 0

  name = local.iam_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      jsondecode(data.spacelift_aws_integration_attachment_external_id.this.assume_role_policy_statement),
    ]
  })
}

# ---------------------------------------------------
# ATTACH THE IAM POLICIES TO THE SPACELIFT IAM ROLE
# ---------------------------------------------------

resource "aws_iam_role_policy_attachment" "this" {
  # We need to attach each policy only if the role is created.
  for_each = {
    for i, policy_arn in var.iam_role_policy_arns :
    i => policy_arn
    if var.create_iam_role
  }

  role       = aws_iam_role.this.id
  policy_arn = each.value

  depends_on = [
    aws_iam_role.this
  ]
}

# ---------------------------------------------------
# ATTACH THE AWS IAM ROLE TO THE SPACELIFT STACK
# ---------------------------------------------------

resource "spacelift_aws_integration_attachment" "this" {
  integration_id = spacelift_aws_integration.this.id
  stack_id       = spacelift_stack.this.id
  read           = true
  write          = true

  # The role needs to exist before we attach since we test role assumption during attachment.
  depends_on = [
    aws_iam_role.this
  ]
}
