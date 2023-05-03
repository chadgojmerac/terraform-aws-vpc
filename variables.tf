variable "vpc_name"{
  type = string
}

variable "vpc_cidr"{
  type = string
  default = "10.0.0.0/24"
}

variable "region" {
  type    = string
  default = "us-west-2"
}

variable "create_public_subnets" {
  type    = bool
  default = true
}

variable "create_database_subnets" {
  type    = bool
  default = true
}

variable "tags"{
  description = "(Optional) tags to add to all resources created by this module"
  type        = map
  default     = {} 
}

variable "subnet_tags"{
  description = "(Optional) tags to add to all public & private subnets"
  type        = map
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
  private_cidr = cidrsubnet(var.vpc_cidr, 1, 0) # First half of var.vpc_cidr (/25)
  public_cidr  = cidrsubnet(var.vpc_cidr, 2, 2) # 3rd quarter of var.vpc_cidr (/26)
  db_cidr      = cidrsubnet(var.vpc_cidr, 2, 3) # 4rd quarter of var.vpc_cidr (/26)

  intra_cidrs = [
    cidrsubnet(local.private_cidr, 3, 0), # First half of 2,0 (/27) (/28)
    cidrsubnet(local.private_cidr, 3, 1), # second half of 2,0 (/27) (/28)
  ]
  private_cidrs = [
    cidrsubnet(local.private_cidr, 2, 1), # /27
    cidrsubnet(local.private_cidr, 2, 2), # /27
    cidrsubnet(local.private_cidr, 2, 3)  # /27
  ]
  public_cidrs = [
    cidrsubnet(local.public_cidr, 2, 0),
    cidrsubnet(local.public_cidr, 2, 1),
    cidrsubnet(local.public_cidr, 2, 2)
  ]
  db_cidrs = [
    cidrsubnet(local.db_cidr, 2, 0),
    cidrsubnet(local.db_cidr, 2, 1),
    cidrsubnet(local.db_cidr, 2, 2)
  ]
}

# Private = half of entire cidr (split into 4, First used for intra_cidrs)
# Public = quarter of entire cidr (split into 3, last not used)
# DB     = quarter of entire cidr (split into 3, last not used)


# /23 - 512 IPs
#   /25 - 128 IPs per /25
#   /25
#   /25
#   /25 further split
#     /27 - 32 IPs per /27
#     /27
#     /27
#     /27 - unused
