
data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_vpc" "default" {
  default = true
}

# testing pupose we are writing output module 

# output "azs_info" {
#     value = data.aws_availability_zones.available
# }

# 🔍 data source to give default vpc main route table terraform

data "aws_route_table" "main" {
  vpc_id = data.aws_vpc.default.id  # <--- 
  filter {
    name = "association.main"
    values = ["true"]
  }
}