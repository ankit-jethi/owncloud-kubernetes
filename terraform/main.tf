provider "aws" {
  region = var.aws_region
}

terraform {
  backend "s3" {
    encrypt = true
  }
}

#---------VPC-----------

resource "aws_vpc" "oc" {
  cidr_block = var.vpc_cidr_block
  enable_dns_support = var.vpc_enable_dns_support
  enable_dns_hostnames = var.vpc_enable_dns_hostnames

  tags = var.vpc_tags
}
