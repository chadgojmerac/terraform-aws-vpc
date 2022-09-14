# terraform-aws-vpc

Create a VPC with 3 private subnets, and the ability to create 3 public subnets.
Uses the cidrsubnet function to automatically split up the vpc_cidr into smaller CIDRs for subnets, regardless of input vpc_cidr size. 

# Variables
## Required
vpc_name
vpc_cidr

## Optional
create_public_subnets (bool)

# Resources