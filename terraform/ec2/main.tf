# module "bastion-host" {
#   source                        = "../modules/ec2"
#   name                          = "Bastion-host"
#   ami                           = "ami-03060465516794b47"
#   ami-owner                     = "099720109477" // Amazon is the owner
#   region                        = "ap-southeast-1"
#   instance-type                 = var.instance-type
#   root-volume-size              = 10
#   vpc-id                        = data.terraform_remote_state.network.outputs.dev-remediation-vpc.id
#   security-group-name           = var.security-group-name
#   ebs-volume-count              = 0 // increase this value if you want to add more disk
#   allowed-ports                 = [22]
#   assign-eip-address            = false
#   create-default-security-group = true
#   generate-ssh-key-pair         = true
#   ssh-key-pair-path             = "./"
#   subnet                        = data.terraform_remote_state.network.outputs.dev-public-subnet-0.id
#   availability-zone             = data.terraform_remote_state.network.outputs.dev-public-subnet-0.availability_zone
#   instance-count                = 1
#   iam-role-default-name         = var.iam-role-default-name
#   iam-instance-profile-name     = var.iam-instance-profile-name
#   owner                         = var.owner
#   project                       = var.project
#   environment                   = var.environment
#   ebs-volume-name               = "volume of the Bastion host"
# }

module "bastion-host" {
  source = "../modules/ec2"
  name                          = "Bastion-host"

  ec2-instances                 = local.bastion_hosts
  generate-ssh-key-pair         = true
  owner                         = var.owner
  project                       = var.project
  environment                   = var.environment
}