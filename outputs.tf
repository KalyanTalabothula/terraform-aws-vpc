
# output.tf folder is updated, now go and check in your vpc-module-test this output.tf folder is came to your vpc-module-test (or) NOT. If NOT just go to your vpc-module-test folder in Gitbash enter terraform init -upgrade enter that's it. Happy learning. 😄

output "vpc_id" {
    value = aws_vpc.main.id   #for vpc Id 
}

output "public_subnet_ids" {      # <--- list kada 
    value = aws_subnet.public[*].id
}

# value = aws_subnet.public[*].id means, terraform-aws-vpc (module creation team) lo vpc.tf lo line number : 40 lo chuste you will understand, [ of star ] id ani este everything ani ardham yenni public subnets unte anni id's output evvu ani ardham. 

output "private_subnet_ids" {      # <--- list kada 
    value = aws_subnet.private[*].id
}

output "database_subnet_ids" {      # <--- list kada 
    value = aws_subnet.datebase[*].id
}
