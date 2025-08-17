locals {
    common_tags = {
        Project = var.project
        Environment = var.environment
        Terraform = "true"
    }
    
    az_names = slice(data.aws_availability_zones.available.names, 0, 2)
}

# ela este yenni availability zones unnayo avi anni namaes vastee
# 🔍 select first 2 in a list terraform

# Example: slice(["a", "b", "c", "d"], 1, 3)
# [
#   "b",  # Inclusive
#   "c",  # Exclusive
# ]

