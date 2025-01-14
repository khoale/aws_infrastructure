provider "aws" {
  region  = "ap-southeast-1"
  profile = "sd1572.nashtech.saml"
}

terraform {
  required_version = "~> 1.6.2"

  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 4.67.0"
    }
  }
  backend "s3" {
    bucket         = "terraform-boostrap-nashtech-devops-1572"
    key            = "terraform.tfstate"
    region         = "ap-southeast-1"
    dynamodb_table = "terraform-boostrap-nashtech-devops-1572"
    profile        = "sd1572.nashtech.saml"
    encrypt        = true
    kms_key_id     = "fff758c9-658d-4a49-98c4-3fabf9b7384d"
  }
}
