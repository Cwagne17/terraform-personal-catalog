# -----------------------------------------------------

# ENVIRONMNENT VARIABLES

# Define these secrets as environment variables

# -----------------------------------------------------

# AWS_ACCESS_KEY_ID

# AWS_SECRET_ACCESS_KEY


# --------------------------------------------------------------------

# REQUIRED PARAMETERS

# These values are required by the module and have no default values

# --------------------------------------------------------------------

variable "api_key_endpoint" {
  description = "The Spacelift API endpoint to use for authenticating to the Spacelift API."
  type        = string
}

variable "branch" {
  description = "GitHub branch to apply changes to"
  type        = string
}

variable "repository" {
  description = "Name of the repository, without the owner part"
  type        = string
}

variable "spacelift_key_id" {
  description = "The Spacelift API key ID to use for authenticating to the Spacelift API."
  type        = string
}

variable "spacelift_key_secret" {
  description = "The Spacelift API key secret to use for authenticating to the Spacelift API."
  type        = string
}

# --------------------------------------------------------------------

# OPTIONAL PARAMETERS

# These values are optional and have default values

# --------------------------------------------------------------------

variable "aws_region" {
  description = "AWS region to deploy the stack to"
  type        = string
  default     = "us-east-1"
}
