# 🔍 terraform aws vpc

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