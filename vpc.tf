data "aws_availability_zones" "available" {}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.7.0"

  name                 = var.vpc_name
  cidr                 = var.vpc_cidr
  azs                  = data.aws_availability_zones.available.names
  private_subnets      = [ local.subnet0_cidr, local.subnet1_cidr, local.subnet2_cidr ]
  public_subnets       = var.create_public_subnets ? [ local.pub_subnet0_cidr, local.pub_subnet1_cidr, local.pub_subnet2_cidr ] : []
  enable_nat_gateway   = false
  single_nat_gateway   = false
  enable_dns_hostnames = true

  tags = merge(tomap({
    "creator" = "terraform-do-not-manually-delete"}),
    var.tags,
  )

  private_subnet_tags = {
    "creator"     = "terraform-do-not-manually-delete"
    "scope"       = "private"
  }
}

output "vpc"{
  value = module.vpc
}

output "vpc_id"{
  value = module.vpc.vpc_id
}

output "private_subnets"{
  value = module.vpc.private_subnets
}

output "public_subnets"{
  value = module.vpc.public_subnets
}