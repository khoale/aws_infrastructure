module "ecr" {
  source      = "../modules/ecr"
  name        = "ecr"
  project     = "nashtech-devops"
  environment = "mgmt"
  owner       = "sd1572"
}
