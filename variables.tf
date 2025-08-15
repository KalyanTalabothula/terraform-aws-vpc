variable "project" {
    type = string
}

variable "environment" {
    type = string 
}

variable "cidr_block" {
    default = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {    # <-- s
    type = list(string)
}

