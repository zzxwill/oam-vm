variable "subnet_id" {
  description = "The ID of the subnet to create the instance in."
  type        = string
}

variable "vpc_security_group_ids" {
  description = "The IDs of the VPC security groups to assign to the instance."
  type        = list(string)
}

variable "code_repo" {
  description = "The Git URL of the web repository to clone."
  type        = string
}