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
  description = "Tags for your VPC."
  type = map(string)
}
