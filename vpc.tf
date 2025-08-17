# 🔍 aws terraform vpc
# Naming convention

resource "aws_vpc" "main" {
  cidr_block       = var.cidr_block 
  instance_tenancy = "default"
  enable_dns_hostnames = true

  tags = merge(
    local.common_tags,
    {
        Name = "${var.project}-${var.environment}"
    }
  )
}

# 🔍 aws terraform Internet gate way
# Internet Gate way (IGW)

resource "aws_internet_gateway" "main" {  # association with VPC
  vpc_id = aws_vpc.main.id

  tags = merge(
    local.common_tags,
    {
        Name = "${var.project}-${var.environment}"
    }
  )
}

# 🔍 aws terraform subnet
# Subnet 

# Availbility Zone 
# manaki name roboshop-dev-us-east-1a ani ravali 
# 🔍 aws availability zones data sources terraform

resource "aws_subnet" "public" {        # <-- main
  count = length(var.public_subnet_cidrs)  
  vpc_id     = aws_vpc.main.id
  cidr_block = var.public_subnet_cidrs[count.index]             # Not var.cidr_block its subnet

  availability_zone = local.az_names[count.index]
 #  availability_zone = data.aws_availability_zones.available.names 
  map_public_ip_on_launch = true

  tags = merge(
    local.common_tags,
    {
        Name = "${var.project}-${var.environment}-public-${local.az_names[count.index]}"
    }
  )
}
