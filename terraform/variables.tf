variable "aws_region" {
  description = "The AWS region you want to create your infrastructure in."
  type = string
  default = "ap-south-1"
}

variable "vpc_cidr_block" {
  description = "The CIDR block for the VPC."
  type = string
}

variable "vpc_enable_dns_support" {
  description = "Indicates whether the DNS resolution is supported."
  type = bool
}

variable "vpc_enable_dns_hostnames" {
  description = "Indicates whether instances with public IP addresses get corresponding public DNS hostnames."
  type = bool
}

variable "vpc_tags" {
  description = "Tags for the VPC."
  type = map(string)
}

variable "subnet_cidr_blocks" {
  description = "The CIDR blocks for the subnets."
  type = map(string)
}

variable "subnet_availability_zones" {
  description = "The AZs for the subnets."
  type = map(string)
}

variable "subnet_tags" {
  description = "Tags for the subnets."
  type = map(map(string))
}

variable "internet_gateway_tags" {
  description = "Tags for the internet gateway."
  type = map(string)
}

variable "public_route_table_tags" {
  description = "Tags for the public route table."
  type = map(string)
}

