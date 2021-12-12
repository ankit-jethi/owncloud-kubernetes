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

variable "allowed_cidr_blocks" {
  description = "A list of CIDR blocks to be allowed SSH access to the Bastion. Also, allowed SSH, HTTP and HTTPS access to Kibana. Eg. Your Public IP address."
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

variable "efs_security_group_name" {
  description = "Name for the EFS Security Group."
  type = string
}

variable "efs_security_group_description" {
  description = "Description for the EFS Security Group."
  type = string
}

variable "efs_security_group_tags" {
  description = "Tags for the EFS Security Group."
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

variable "elk_security_group_name" {
  description = "Name for the Elastic Stack Security Group."
  type = string
}

variable "elk_security_group_description" {
  description = "Description for the Elastic Stack Security Group."
  type = string
}

variable "elk_security_group_tags" {
  description = "Tags for the Elastic Stack Security Group."
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

variable "enabled_cloudwatch_logs_exports" {
  description = "A list of all the log types that you want to export to Cloudwatch."
  type = list(string)
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

variable "k8s_master" {
  description = "A map of all the data required to setup the K8s master instance."
  type = map(string)
}

variable "k8s_master_tags" {
  description = "Tags for the K8s master instance."
  type = map(string)
}

variable "k8s_worker" {
  description = "A map of all the data required to setup the K8s worker instance."
  type = map(string)
}

variable "k8s_worker_tags" {
  description = "Tags for the K8s worker instance."
  type = map(string)
}

variable "k8s_instance_login_user" {
  description = "Name of the login user of the K8s instances."
  type = string
}

variable "lb_name" {
  description = "Name of the Load Balancer."
  type = string
}

variable "lb_tags" {
  description = "Tags for the Load Balancer."
  type = map(string)
}

variable "lb_target_group_name" {
  description = "Name of the Load Balancer target group."
  type = string
}

variable "lb_target_group_tags" {
  description = "Tags for the Load Balancer target group."
  type = map(string)
}

variable "efs_file_system" {
  description = "A map of all the data required to setup the EFS file system."
  type = map(string)
}

variable "efs_file_system_tags" {
  description = "Tags for the EFS file system."
  type = map(string)
}

variable "elk" {
  description = "A map of all the data required to setup the Elastic Stack instance."
  type = map(string)
}

variable "elk_tags" {
  description = "Tags for the Elastic Stack instance."
  type = map(string)
}

variable "elk_instance_login_user" {
  description = "Name of the login user of the Elastic Stack instance."
  type = string
}

variable "domain_name" {
  description = "Your domain name for eg. sabkacloud.xyz"
  type = string
}

variable "email_address" {
  description = "Your email address for Let's Encrypt certificate."
  type = string
}

variable "delegation_set_id" {
  description = "The ID of your Route 53 delegation set for use with the Public Hosted Zone."
  type = string
}

variable "public_hosted_zone_description" {
  description = "Description of the Public Hosted Zone."
  type = string
}

variable "public_hosted_zone_tags" {
  description = "Tags for the Public Hosted Zone."
  type = map(string)
}

variable "private_hosted_zone_description" {
  description = "Description of the Private Hosted Zone."
  type = string
}

variable "private_hosted_zone_tags" {
  description = "Tags for the Private Hosted Zone."
  type = map(string)
}

variable "iam_policy_route53" {
  description = "A map of all the data required to setup the IAM policy with Route 53 access."
  type = map(string)
}

variable "iam_policy_route53_tags" {
  description = "Tags for the IAM policy with Route 53 access."
  type = map(string)
}

variable "iam_policy_acm" {
  description = "A map of all the data required to setup the IAM policy with ACM access."
  type = map(string)
}

variable "iam_policy_acm_tags" {
  description = "Tags for the IAM policy with ACM access."
  type = map(string)
}

variable "iam_role_ec2_route53" {
  description = "A map of all the data required to setup the IAM role for EC2 to access Route 53."
  type = map(string)
}

variable "iam_role_ec2_route53_tags" {
  description = "Tags for the IAM role for EC2 to access Route 53."
  type = map(string)
}

variable "iam_role_ec2_route53_acm" {
  description = "A map of all the data required to setup the IAM role for EC2 to access Route 53 and ACM."
  type = map(string)
}

variable "iam_role_ec2_route53_acm_tags" {
  description = "Tags for the IAM role for EC2 to access Route 53 and ACM."
  type = map(string)
}

variable "instance_profile_route53_name" {
  description = "Name of the instance profile with Route 53 access."
  type = string
}

variable "instance_profile_route53_tags" {
  description = "Tags for the instance profile with Route 53 access."
  type = map(string)
}

variable "instance_profile_route53_acm_name" {
  description = "Name of the instance profile with Route 53 and ACM access."
  type = string
}

variable "instance_profile_route53_acm_tags" {
  description = "Tags for the instance profile with Route 53 and ACM access."
  type = map(string)
}
