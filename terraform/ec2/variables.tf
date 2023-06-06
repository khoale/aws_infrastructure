variable "project" {}

variable "environment" {}

variable "owner" {}

variable "instance-type" {
  default = "t2.micro"
}

variable "iam-role-default-name" {}

variable "iam-instance-profile-name" {}

variable "security-group-name" {}
