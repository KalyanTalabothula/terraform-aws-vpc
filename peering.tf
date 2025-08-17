
# 🔍 aws vpc peering terraform
# 🔍 datasource to get default vpc id

resource "aws_vpc_peering_connection" "default" {  # foo --> default
    count = var.is_peering_required ? 1 : 0

 # peer_owner_id = var.peer_owner_id
  peer_vpc_id   = data.aws_vpc.default.id # accecptor for that we need default VPC-Id from datasource to get default vpc-id
  vpc_id        = aws_vpc.main.id   # requestor

  accepter {
    allow_remote_vpc_dns_resolution = true
  }

  requester {
    allow_remote_vpc_dns_resolution = true
  }

  auto_accept = true

  tags = merge(
    var.vpc_peering_tags,
    local.common_tags,
    {
        Name = "${var.project}-${var.environment}-default"
    }
  )
}


# False ite 0, true ani estae variables lo 1 is true

# peer_owner_id = var.peer_owner_id no need becase we are using the our own account

# Miru production ite miru deniki kavalo dhaniki matrame add cheyamdii.

resource "aws_route" "public_peering" {     # r --> public
    count = var.is_peering_required ? 1 : 0
  route_table_id            = aws_route_table.public.id  # testing --> public
  destination_cidr_block    = data.aws_vpc.default.cidr_block   # "10.0.1.0/22"
  vpc_peering_connection_id = aws_vpc_peering_connection.default[count.index].id  # <-- carefull
}

resource "aws_route" "private_peering" {     
    count = var.is_peering_required ? 1 : 0
  route_table_id            = aws_route_table.private.id  
  destination_cidr_block    = data.aws_vpc.default.cidr_block  
  vpc_peering_connection_id = aws_vpc_peering_connection.default[count.index].id  # <-- carefull
}

resource "aws_route" "database_peering" {     
    count = var.is_peering_required ? 1 : 0
  route_table_id            = aws_route_table.database.id  
  destination_cidr_block    = data.aws_vpc.default.cidr_block   
  vpc_peering_connection_id = aws_vpc_peering_connection.default[count.index].id  # <-- carefull
}

# We should add peering connection in default VPC main route table too... 

resource "aws_route" "default_peering" {     
    count = var.is_peering_required ? 1 : 0   # <-- carefull
  route_table_id            = data.aws_route_table.main.id       # <-- carefull
  destination_cidr_block    = var.cidr_block        # <-- carefull
  vpc_peering_connection_id = aws_vpc_peering_connection.default[count.index].id  
}