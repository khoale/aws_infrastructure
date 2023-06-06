module "bastion-host" {
  source = "../modules/ec2"
  name                          = "Bastion-host"

  ec2-instances                 = local.bastion_hosts
  generate-ssh-key-pair         = true
  owner                         = var.owner
  project                       = var.project
  environment                   = var.environment
}