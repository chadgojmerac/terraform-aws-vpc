data "aws_availability_zones" "available" {}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.7.0"

  name                 = var.vpc_name
  cidr                 = var.vpc_cidr
  azs                  = data.aws_availability_zones.available.names
  intra_subnets        = local.intra_cidrs
  private_subnets      = local.private_cidrs
  public_subnets       = var.create_public_subnets ? local.public_cidrs : []
  database_subnets     = var.create_database_subnets ? local.db_cidrs : []
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true
  public_subnet_tags   = var.subnet_tags
  private_subnet_tags  = var.subnet_tags

  tags = merge(tomap({
    "creator" = "terraform-do-not-manually-delete"}),
    var.tags,
  )
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

output "database_subnets"{
  value = module.vpc.database_subnets
}