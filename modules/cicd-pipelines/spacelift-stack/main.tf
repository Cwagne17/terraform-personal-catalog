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
      version = ">= 5.0"
    }
    spacelift = {
      source  = "spacelift-io/spacelift"
      version = ">= 1.1.9"
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
    for_each = var.terragrunt_version != null ? [1] : []

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
  protect_from_deletion = var.protect_from_deletion
  repository            = var.repository

  terraform_smart_sanitization = true
  terraform_version            = var.terraform_version

}


# ---------------------------------------------------
# DEFINE THE SPACELIFT STACK ENVIRONMENT VARIABLES
# ---------------------------------------------------

resource "spacelift_environment_variable" "this" {
  count = length(var.environment_variables)

  stack_id = spacelift_stack.this.id

  name       = var.environment_variables[count.index].name
  value      = var.environment_variables[count.index].value
  write_only = try(var.environment_variables[count.index].sensitive, false)
}


# ---------------------------------------------------
# DEFINE THE SPACELIFT STACK MOUNTED FILES
# ---------------------------------------------------

resource "spacelift_mounted_file" "this" {
  count = length(var.mounted_files)

  stack_id = spacelift_stack.this.id

  content       = filebase64("${path.module}/${var.mounted_files[count.index].path}")
  relative_path = var.mounted_files[count.index].relative_path
}


# ---------------------------------------------------
# ATTACH THE SPACELIFT CONTEXT TO THE STACK
# ---------------------------------------------------

resource "spacelift_context_attachment" "this" {
  count = length(var.context_ids)

  context_id = var.context_ids[count.index]
  stack_id   = spacelift_stack.this.id

  priority = count.index
}


# ---------------------------------------------------
# ATTACH THE SPACELIFT POLICIES TO THE STACK
# ---------------------------------------------------

resource "spacelift_policy_attachment" "this" {
  count = length(var.policy_ids)

  policy_id = var.policy_ids[count.index]
  stack_id  = spacelift_stack.this.id
}

# ---------------------------------------------------
# CREATE STACK DESTRUCTOR
# ---------------------------------------------------

resource "spacelift_stack_destructor" "this" {
  depends_on = [
    spacelift_environment_variable.this,
    spacelift_mounted_file.this,
    spacelift_policy_attachment.this,
    spacelift_context_attachment.this,
  ]

  stack_id = spacelift_stack.this.id
}

# ---------------------------------------------------
# ADD ANY STACK DEPENDENCIES
# ---------------------------------------------------

resource "spacelift_stack_dependency" "this" {
  count = length(var.stack_dependency_ids)

  stack_id            = spacelift_stack.this.id
  depends_on_stack_id = var.stack_dependency_ids[count.index]
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

  integration_id = spacelift_aws_integration.this[1].id
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
      jsondecode(data.spacelift_aws_integration_attachment_external_id.this[1].assume_role_policy_statement),
    ]
  })
}

# ---------------------------------------------------
# ATTACH THE IAM POLICIES TO THE SPACELIFT IAM ROLE
# ---------------------------------------------------

resource "aws_iam_role_policy_attachment" "this" {
  count = var.create_iam_role ? length(var.iam_role_policy_arns) : 0

  role       = aws_iam_role.this[1].id
  policy_arn = var.iam_role_policy_arns[count.index]
}

# ---------------------------------------------------
# ATTACH THE AWS IAM ROLE TO THE SPACELIFT STACK
# ---------------------------------------------------

resource "spacelift_aws_integration_attachment" "this" {
  count = var.create_iam_role ? 1 : 0

  integration_id = spacelift_aws_integration.this[1].id
  stack_id       = spacelift_stack.this.id
  read           = true
  write          = true

  # The role needs to exist before we attach since we test role assumption during attachment.
  depends_on = [
    aws_iam_role.this,
  ]
}
