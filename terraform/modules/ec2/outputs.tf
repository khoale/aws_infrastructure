output "ec2-instances" {
  value = { for index, v in aws_instance.default : "${v.tags_all.Name}-${index}" => v.private_dns }
}

output "instance-inputs" {
  value = { for index, v in local.ec2-instances : index => v.instance }
}

output "default-profiles" {
  value = local.default_profiles
}

output "ebscount-tmp" {
  value = local.ebs-volume-tmp
}

output "ebscount" {
  value = local.ebs-volume
}

output "instance-inputs-raw" {
  value = local.ec2-instances
}