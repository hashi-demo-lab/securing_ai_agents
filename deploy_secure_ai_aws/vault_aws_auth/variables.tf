
variable "aws_region" {
  description = "AWS Region to be used"
  type = string
  default = "us-east-1"

  validation {
  condition = can(regex("[a-z][a-z]-[a-z]+-[1-9]", var.aws_region))
  error_message = "Must be a valid AWS Region name."
  }
}