locals {
  root-iops            = var.root-volume-type == "io1" ? var.root-iops : 0
  ebs-iops             = var.ebs-volume-type == "io1" ? var.ebs-iops : 0
  availability-zone    = var.availability-zone
  ssh-key-pair-path    = var.ssh-key-pair-path == "" ? path.cwd : var.ssh-key-pair-path

  ec2-instances = flatten([
    for value in var.ec2-instances : [
      for replica in range(value.instance-count) : {
        instance = value
      }
    ]
  ])

  ec2-instances-good-form = { for key, v in local.ec2-instances : key => v.instance }

  default_profiles = { for key, v in distinct(local.ec2-instances[*].instance.iam-instance-profile-name) : key => v }

  ebs-volume-tmp = flatten([
    for index, value in local.ec2-instances : [
      for ebscount in range(value.instance.ebs-volume-count) : {
        az        = value.instance.availability-zone
        ebs-count = value.instance.ebs-volume-count
        ins-count = value.instance.instance-count
        key       = index
        size      = value.instance.ebs-volume-size
      }
    ]
  ])

  ebs-volume = { for index, value in local.ebs-volume-tmp : index => value }
}

module "ebs-volume-tags" {
  source = "../tags"

  name        = var.ebs-volume-name
  project     = var.project
  environment = var.environment
  owner       = var.owner

  tags = {
    Description = "managed by terraform",
  }
}

module "ec2-instance-tags" {
  source = "../tags"

  name        = var.name
  project     = var.project
  environment = var.environment
  owner       = var.owner

  tags = {
    Description = "managed by terraform",
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_caller_identity" "default" {
}

data "aws_iam_policy_document" "default" {
  statement {
    sid = "ec2defaultpolicy"

    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    effect = "Allow"
  }
}

data "aws_ami" "info" {
  for_each = { for index, v in local.ec2-instances : index => v.instance }
  filter {
    name   = "image-id"
    values = [lookup(each.value, "ami", "ami-03060465516794b47")]
  }

  owners = [lookup(each.value, "ami-owner", "099720109477")]
}

resource "aws_iam_instance_profile" "default" {
  for_each = { for key, v in local.default_profiles : key => v }
  name     = each.value
  role     = lookup(local.ec2-instances-good-form[each.key], "iam-role-default-name", null)
}

resource "aws_instance" "default" {
  for_each                    = { for key, v in local.ec2-instances : key => v.instance }
  ami                         = data.aws_ami.info[each.key].id
  availability_zone           = lookup(each.value, "availability-zone", data.aws_availability_zones.available.names[0])
  instance_type               = lookup(each.value, "instance-type", "t3a.nano")
  ebs_optimized               = lookup(each.value, "ebs-optimized", false)
  disable_api_termination     = lookup(each.value, "disable-api-termination", false)
  user_data                   = lookup(each.value, "user-data", false)
  iam_instance_profile        = one([ for v in local.default_profiles : v if lookup(each.value, "iam-instance-profile-name", null) == v])
  associate_public_ip_address = lookup(each.value, "associate_public_ip_address", false)
  key_name                    = lookup(each.value, "ssh-key-pair", null) != null && signum(length(lookup(each.value, "ssh-key-pair", ""))) == 1 ? lookup(each.value, "ssh-key-pair", null) : module.ssh_key_pair.key_name
  subnet_id                   = lookup(each.value, "subnet_id", null)
  monitoring                  = lookup(each.value, "monitoring", null)
  private_ip                  = lookup(each.value, "private-ip", null)
  source_dest_check           = lookup(each.value, "source-dest-check", null)
  ipv6_address_count          = var.ipv6-address-count < 0 ? null : var.ipv6-address-count
  ipv6_addresses              = lookup(each.value, "ipv6-addresses", null) != null && length(lookup(each.value, "ipv6-addresses", "")) > 0 ? var.ipv6-addresses : null

  vpc_security_group_ids = lookup(each.value, "security-groups", null)

  root_block_device {
    volume_type           = var.root-volume-type != "" ? var.root-volume-type : data.aws_ami.info[each.key].root_device_type
    volume_size           = lookup(each.value, "root-volume-size", "10")
    iops                  = local.root-iops
    delete_on_termination = var.delete-on-termination
  }

  tags = module.ec2-instance-tags.tags
}

resource "aws_network_interface_sg_attachment" "sg_attachment" {
  for_each             = { for index, v in local.ec2-instances : index => v.instance }
  security_group_id    = lookup(each.value, "security-group-ids", null)
  network_interface_id = aws_instance.default[each.key].primary_network_interface_id
}

##
## Create keypair if one isn't provided
##

module "ssh_key_pair" {
  source                = "../key_pair"
  environment           = var.environment
  project               = var.project
  name                  = var.name
  ssh_public_key_path   = local.ssh-key-pair-path
  private_key_extension = ".pem"
  public_key_extension  = ".pub"
  generate_ssh_key      = var.generate-ssh-key-pair
}

resource "aws_ebs_volume" "default" {
  for_each          = { for index, v in local.ebs-volume : index => v }
  availability_zone = lookup(each.value, "az", data.aws_availability_zones.available.names[0])
  size              = lookup(each.value, "size", 10)
  iops              = local.ebs-iops
  type              = var.ebs-volume-type
  tags              = module.ebs-volume-tags.tags
}

resource "aws_volume_attachment" "default" {
  for_each    = { for index, v in local.ebs-volume : index => v }
  device_name = element(slice(var.ebs-device-names, 0, floor(each.value.ebs-count * each.value.ins-count / max(each.value.ins-count, 1))), each.key)
  volume_id   = aws_ebs_volume.default[each.key].id
  instance_id = aws_instance.default[each.value.key].id
}