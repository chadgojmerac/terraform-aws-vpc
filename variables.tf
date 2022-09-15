variable "vpc_name"{
    default = "test-vpc"
}

variable "vpc_cidr"{
    default = "10.12.0.0/24"
}

variable "region" {
    type = string
    default = "us-west-2"
}

variable "create_public_subnets" {
  type = bool
  default = true
}

variable "tags"{
  description = "Tags to add to all resources created by this module"
  default = {} 
}
# 
# Assuming we get "10.0.0.0/16" as an input for var.vpc_cidr and we want to divide it into /24 networks
# we subtract /16 from the /24, and are left with 8 (24 - 16 = 8). This 8 is the second parameter used
# in the cidrsubnet() built-in TerraForm function
#
#   subnet0_cidr   = cidrsubnet(var.vpc_cidr, 8, 0)   # 10.0.0.0/24 using the  10.0.0.0/16 vpc_cidr value
#   subnet127_cidr = cidrsubnet(var.vpc_cidr, 8, 127) # 10.0.127.0/24 using the 10.0.0.0/16 vpc_cidr value
#
# 
# Number of divisions of the network
#
# 2^1 = 2
# 2^2 = 4
# 2^3 = 8
# 2^4 = 16 
# 2^5 = 32 
# 2^6 = 64 
# 2^7 = 128
# 2^8 = 256
#
# For this module instead what we want to do is divide ANY CIDR given as an input into 4 equal parts.
#   3 CIDRs are going to be used for private subnets across multiple AZs
#   last remaining CIDR will be available to create public subnets on if needed later. (subnet3_cidr)

locals {
  # the local.subnetX_cidr variables are the subnets resultant from splitting the vpc_cidr var into 4 equal subnets.
  subnet0_cidr = cidrsubnet(var.vpc_cidr, 2, 0) # 10.63.250.0/25 using default vpc_cidr value on /25 cidr.
  subnet1_cidr = cidrsubnet(var.vpc_cidr, 2, 1) # 10.63.250.128/25 using default vpc_cidr value
  subnet2_cidr = cidrsubnet(var.vpc_cidr, 2, 2) # 10.63.251.0/25 using default vpc_cidr value
  subnet3_cidr = cidrsubnet(var.vpc_cidr, 2, 3) # 10.63.251.128/25 using default vpc_cidr value

  pub_subnet0_cidr = cidrsubnet(local.subnet3_cidr,2, 0)
  pub_subnet1_cidr = cidrsubnet(local.subnet3_cidr,2, 1)
  pub_subnet2_cidr = cidrsubnet(local.subnet3_cidr,2, 2)
}

# /23 - 512 IPs
#   /25 - 128 IPs per /25
#   /25
#   /25
#   /25 further split
#     /27 - 32 IPs per /27
#     /27
#     /27
#     /27 - unused
