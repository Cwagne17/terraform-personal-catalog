# -----------------------------------------------------------------------------
# MODULE PARAMETERS
#
# These values are expected to be set by the operator when calling the module
# -----------------------------------------------------------------------------


# --------------------------------------------------------------------
# REQUIRED PARAMETERS
#
# These values are required by the module and have no default values
# --------------------------------------------------------------------


variable "branch" {
  description = "GitHub branch to apply changes to"
  type        = string
}

variable "stack_name" {
  description = "Name of the stack - should be unique in one account"
  type        = string
}

variable "repository" {
  description = "Name of the repository, without the owner part"
  type        = string
}

# --------------------------------------------------------------------
# OPTIONAL PARAMETERS
#
# These values are optional and have default values provided
# --------------------------------------------------------------------

variable "autodeploy" {
  description = "Whether to automatically deploy changes to the stack"
  type        = bool
  default     = false
}

variable "create_iam_role" {
  description = "Whether to create an IAM role for the stack"
  type        = bool
  default     = true
}

variable "description" {
  description = "Description of the stack"
  type        = string
  default     = "A stack managed by Terraform"
}

variable "enable_admin_stack" {
  description = "Whether to enable administrative access to the stack to manage other Spacelift stacks and resources"
  type        = bool
  default     = false
}

variable "enable_state_management" {
  description = "Whether to enable state management for the stack. If disabled, the implementation of the module should define another remote backend such as S3."
  type        = bool
  default     = false
}

variable "iam_role_policy_arns" {
  description = "IAM role policy ARNs to attach to the stack's IAM role. The IAM role will be created if create_iam_role is true. The policies ARNs can either be ARNs of AWS managed policies or custom policies."
  type        = list(string)
  default     = []
}

variable "labels" {
  description = "Labels to assign to the stack"
  type        = list(string)
  default     = []
}

variable "project_root" {
  description = "Path to the root of the project"
  type        = string
  default     = null
}

variable "terraform_version" {
  description = "Terraform version to use, if not set it will default to the latest version of terraform"
  type        = string
  default     = null
}

variable "terragrunt_use_run_all" {
  description = "Whether to use terragrunt run-all command"
  type        = bool
  default     = true
}

variable "terragrunt_version" {
  description = "Terragrunt version to use, if not set it will default to the latest version of terragrunt"
  type        = string
  default     = null
}

