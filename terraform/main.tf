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

resource "aws_subnet" "oc_private_1" {
  vpc_id = aws_vpc.oc.id
  cidr_block = var.subnet_cidr_blocks["oc_private_1"]
  availability_zone = var.subnet_availability_zones["oc_private_1"]
  
  tags = var.subnet_tags["oc_private_1"]
}

resource "aws_subnet" "oc_private_2" {
  vpc_id = aws_vpc.oc.id
  cidr_block = var.subnet_cidr_blocks["oc_private_2"]
  availability_zone = var.subnet_availability_zones["oc_private_2"]
  
  tags = var.subnet_tags["oc_private_2"]
}

resource "aws_subnet" "oc_private_3" {
  vpc_id = aws_vpc.oc.id
  cidr_block = var.subnet_cidr_blocks["oc_private_3"]
  availability_zone = var.subnet_availability_zones["oc_private_3"]
  
  tags = var.subnet_tags["oc_private_3"]
}

resource "aws_internet_gateway" "oc" {
  vpc_id = aws_vpc.oc.id
  
  tags = var.internet_gateway_tags
}


resource "aws_route_table" "oc_public" {
  vpc_id = aws_vpc.oc.id
  
  tags = var.public_route_table_tags
}

resource "aws_route" "oc_public" {
  route_table_id = aws_route_table.oc_public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.oc.id
}

resource "aws_route_table_association" "oc_public" {
  for_each = {
    oc_public_1 = aws_subnet.oc_public_1.id
    oc_public_2 = aws_subnet.oc_public_2.id
  }

  subnet_id = each.value
  route_table_id = aws_route_table.oc_public.id
}

resource "aws_eip" "oc_ngw" {
  public_ipv4_pool = "amazon"
  vpc = true
  
  tags = var.eip_ngw_tags
  
  depends_on = [aws_internet_gateway.oc]
}

resource "aws_nat_gateway" "oc" {
  allocation_id = aws_eip.oc_ngw.id
  connectivity_type = "public"
  subnet_id = aws_subnet.oc_public_1.id
  
  tags = var.nat_gateway_tags
  
  depends_on = [aws_internet_gateway.oc]
}

resource "aws_default_route_table" "oc_private" {
  default_route_table_id = aws_vpc.oc.default_route_table_id
  
  route {
      cidr_block = "0.0.0.0/0"
      nat_gateway_id = aws_nat_gateway.oc.id
    }
  
  tags = var.private_route_table_tags
}
