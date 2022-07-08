resource "aws_eip" "lb" {
  instance = var.instance_id
  vpc      = true
}

variable "instance_id" {
  description = "The instance to which the LB will be attached"
  type = string
}