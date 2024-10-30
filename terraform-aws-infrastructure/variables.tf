# variables.tf

variable "aws_region" {
  description = "A região AWS onde os recursos serão criados"
  type        = string
  default     = "eu-central-1"
}

variable "environment" {
  description = "O ambiente onde os recursos serão criados"
  type        = string
  default     = "development"
}
