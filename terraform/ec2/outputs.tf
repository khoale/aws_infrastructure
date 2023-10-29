# output "public_dns" {
#   value = module.sd1572-host.public_dns
# }

# output "public_ip" {
#   value = module.sd1572-host.public_ip
# }

# output "private_dns" {
#   value = module.sd1572-host.private_dns
# }

# output "arn" {
#   value = module.sd1572-host.arn
# }

# output "instance-inputs" {
#   value = module.sd1572-host.instance-inputs
# }

# output "ec2-instances" {
#   value = module.sd1572-host.ec2-instances
# }

output "all" {
  value = module.sd1572-host
}