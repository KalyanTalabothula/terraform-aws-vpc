
data "aws_availability_zones" "available" {
  state = "available"
}

# testing pupose we are writing output module 

# output "azs_info" {
#     value = data.aws_availability_zones.available
# }
