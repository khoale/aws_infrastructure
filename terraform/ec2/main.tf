module "sd1572-host" {
  source = "../modules/ec2"
  name                          = "sd1572-host"

  ec2_instances                 = local.sd1572_hosts
  generate_ssh_key_pair         = true
  owner                         = var.owner
  project                       = var.project
  environment                   = var.environment
}