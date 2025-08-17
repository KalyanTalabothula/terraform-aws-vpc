# 🔍 aws terraform vpc
# Naming convention

resource "aws_vpc" "main" {
  cidr_block       = var.cidr_block 
  instance_tenancy = "default"
  enable_dns_hostnames = true

  tags = merge(
    var.vpc_tags,
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
    var.igw_tags,
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
    var.public_subnet_tags,
    local.common_tags,
    {
        Name = "${var.project}-${var.environment}-public-${local.az_names[count.index]}"
    }
  )
}


resource "aws_subnet" "private" {        # <-- main
  count = length(var.private_subnet_cidrs)  
  vpc_id     = aws_vpc.main.id
  cidr_block = var.private_subnet_cidrs[count.index]             # Not var.cidr_block its subnet

  availability_zone = local.az_names[count.index]
 #  availability_zone = data.aws_availability_zones.available.names 
 # map_public_ip_on_launch = true  because it is private subnet

  tags = merge(
    var.private_subnet_tags,
    local.common_tags,
    {
        Name = "${var.project}-${var.environment}-private-${local.az_names[count.index]}" # change to database
    }
  )
}


resource "aws_subnet" "database" {        # <-- main
  count = length(var.database_subnet_cidrs)  
  vpc_id     = aws_vpc.main.id
  cidr_block = var.database_subnet_cidrs[count.index]             # Not var.cidr_block its subnet

  availability_zone = local.az_names[count.index]
 #  availability_zone = data.aws_availability_zones.available.names 
 # map_public_ip_on_launch = true  because it is private subnet

  tags = merge(
    var.database_subnet_tags,
    local.common_tags,
    {
        Name = "${var.project}-${var.environment}-database-${local.az_names[count.index]}"  # change to database
    }
  )
}

# 🔍 aws eip terraform 

resource "aws_eip" "nat" {  # change 1b to nat
  domain   = "vpc"

  tags = merge(
    var.eip_tags,
    local.common_tags,
    {
      Name = "${var.project}-${var.environment}"
    }
  )
}

# 🔍 aws NAT-Gateway terraform 

resource "aws_nat_gateway" "main" {   # example --> main because of VPC 
  allocation_id = aws_eip.nat.id      # example --> nat
  subnet_id     = aws_subnet.public[0].id      # example --> public[0] because of 2 - subnets unnae kabatti

  tags = merge(
    var.nat_gateway_tags,
    local.common_tags,
    {
      Name = "${var.project}-${var.environment}"
    }
  )

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.main]  # example --> make sure IGW is there. 
}

# 🔍aws route-table terraform 
# For public,private,DB subnets ki route table so we need 3-routetable here. 

resource "aws_route_table" "public" { # example --> public
  vpc_id = aws_vpc.main.id           # example --> main, Manam VPC lo route table create chestunnam

  tags = merge(
    var.public_route_table_tags,   # <---
    local.common_tags,
    {
      Name = "${var.project}-${var.environment}-public"   # keep namae as public, to which routetable
    }
  )
}

resource "aws_route_table" "private" { 
  vpc_id = aws_vpc.main.id           

  tags = merge(
    var.private_route_table_tags,
    local.common_tags,
    {
      Name = "${var.project}-${var.environment}-private"
    }
  )
}

resource "aws_route_table" "database" { 
  vpc_id = aws_vpc.main.id           

  tags = merge(
    var.database_route_table_tags,
    local.common_tags,
    {
      Name = "${var.project}-${var.environment}-database"
    }
  )
}

# 🔍aws route terraform 

resource "aws_route" "public" {     # r --> public
  route_table_id            = aws_route_table.public.id  # testing --> public
  destination_cidr_block    = "0.0.0.0/0"     # "10.0.1.0/22"
  # vpc_peering_connection_id = "pcx-45ff3dc1"
  gateway_id = aws_internet_gateway.main.id  # Not VPC-peering we need route to IGW, so we given
}

resource "aws_route" "private" {     
  route_table_id            = aws_route_table.private.id  
  destination_cidr_block    = "0.0.0.0/0"     # "10.0.1.0/22"
  # vpc_peering_connection_id = "pcx-45ff3dc1"
  nat_gateway_id = aws_nat_gateway.main.id  # here be careful you need to mention NAT-gateway
}

resource "aws_route" "database" {     
  route_table_id            = aws_route_table.database.id  
  destination_cidr_block    = "0.0.0.0/0"     # "10.0.1.0/22"
  # vpc_peering_connection_id = "pcx-45ff3dc1"
  nat_gateway_id = aws_nat_gateway.main.id  # here be careful you need to mention NAT-gateway
}

# 🔍aws route table association terraform 

resource "aws_route_table_association" "public" {    # a --> public
  count = length(var.public_subnet_cidrs)              # <---
  subnet_id      = aws_subnet.public[count.index].id     # <---
  route_table_id = aws_route_table.public.id               # <---
}

resource "aws_route_table_association" "private" {  
  count = length(var.private_subnet_cidrs)   
  subnet_id      = aws_subnet.private[count.index].id   
  route_table_id = aws_route_table.private.id  
}

resource "aws_route_table_association" "database" {  
  count = length(var.database_subnet_cidrs)  
  subnet_id      = aws_subnet.database[count.index].id   
  route_table_id = aws_route_table.database.id  
}

