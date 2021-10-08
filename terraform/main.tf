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

resource "aws_subnet" "oc_public_1" {
  vpc_id = aws_vpc.oc.id
  cidr_block = var.subnet_cidr_blocks["oc_public_1"]
  availability_zone = var.subnet_availability_zones["oc_public_1"]
  map_public_ip_on_launch = true
  
  tags = var.subnet_tags["oc_public_1"]
}

resource "aws_subnet" "oc_public_2" {
  vpc_id = aws_vpc.oc.id
  cidr_block = var.subnet_cidr_blocks["oc_public_2"]
  availability_zone = var.subnet_availability_zones["oc_public_2"]
  map_public_ip_on_launch = true
  
  tags = var.subnet_tags["oc_public_2"]
}
