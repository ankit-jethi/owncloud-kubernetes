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
  description = "Tags for the Internet Gateway."
  type = map(string)
}

variable "public_route_table_tags" {
  description = "Tags for the public route table."
  type = map(string)
}

variable "elastic_ip_ngw_tags" {
  description = "Tags for the Elastic IP address to be associated with the NAT Gateway."
  type = map(string)
}

variable "nat_gateway_tags" {
  description = "Tags for the NAT Gateway."
  type = map(string)
}

variable "private_route_table_tags" {
  description = "Tags for the private route table."
  type = map(string)
}

variable "lb_security_group_name" {
  description = "Name for the Load Balancer Security Group."
  type = string
}

variable "lb_security_group_description" {
  description = "Description for the Load Balancer Security Group."
  type = string
}

variable "lb_security_group_tags" {
  description = "Tags for the Load Balancer Security Group."
  type = map(string)
}

variable "bastion_security_group_name" {
  description = "Name for the Bastion Security Group."
  type = string
}

variable "bastion_security_group_description" {
  description = "Description for the Bastion Security Group."
  type = string
}

variable "bastion_security_group_tags" {
  description = "Tags for the Bastion Security Group."
  type = map(string)
}

variable "cidr_blocks_ssh_bastion" {
  description = "A list of CIDR blocks to be allowed SSH access to the Bastion."
  type = list(string)
}

variable "app_security_group_name" {
  description = "Name for the Application Security Group."
  type = string
}

variable "app_security_group_description" {
  description = "Description for the Application Security Group."
  type = string
}

variable "app_security_group_tags" {
  description = "Tags for the Application Security Group."
  type = map(string)
}

variable "database_security_group_name" {
  description = "Name for the Database Security Group."
  type = string
}

variable "database_security_group_description" {
  description = "Description for the Database Security Group."
  type = string
}

variable "database_security_group_tags" {
  description = "Tags for the Database Security Group."
  type = map(string)
}

variable "db_subnet_group_name" {
  description = "Name for the Database Subnet group."
  type = string
}

variable "db_subnet_group_description" {
  description = "Description for the Database Subnet group."
  type = string
}

variable "db_subnet_group_tags" {
  description = "Tags for the Database Subnet group."
  type = map(string)
}

variable "db_parameter_group_name" {
  description = "Name for the Database Parameter group."
  type = string
}

variable "db_parameter_group_description" {
  description = "Description for the Database Parameter group."
  type = string
}

variable "db_parameter_group_family" {
  description = "The family of the Database Parameter group."
  type = string
}

variable "db_parameter_group_parameters" {
  description = "Parameters for the Database Parameter group."
  type = list(map(string))
}

variable "db_parameter_group_tags" {
  description = "Tags for the Database Parameter group."
  type = map(string)
}

variable "db_instance" {
  description = "A map of all the data required to setup the Database instance."
  type = map(string)
}

variable "db_instance_tags" {
  description = "Tags for the Database instance."
  type = map(string)
}

variable "key_name" {
  description = "The key name to associate with your instances."
  type = string
}

variable "path_to_public_key" {
  description = "The path to the public key to associate with your instances."
  type = string  
}

variable "key_pair_tags" {
  description = "Tags for the key pair."
  type = map(string)
}

variable "bastion_launch_template" {
  description = "A map of all the data required to setup the Bastion launch template."
  type = map(string)
}

variable "bastion_instance_tags" {
  description = "Tags for the Bastion instance."
  type = map(string)
}

variable "bastion_autoscaling_group" {
  description = "A map of all the data required to setup the Bastion Auto Scaling Group."
  type = map(string)
}

variable "bastion_login_user" {
  description = "Name of the login user of the Bastion instance."
  type = string
}
