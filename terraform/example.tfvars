# This is an example file. 
# Change the values in this file and then rename it to terraform.tfvars

aws_region = "ap-south-1"

vpc_cidr_block = "192.168.0.0/16"
vpc_enable_dns_support = true
vpc_enable_dns_hostnames = true
vpc_tags = {
  Name = "oc"
}

subnet_cidr_blocks = {
  oc_public_1 = "192.168.10.0/24"
  oc_public_2 = "192.168.20.0/24"
  oc_private_1 = "192.168.30.0/24"
  oc_private_2 = "192.168.40.0/24"
  oc_database_1 = "192.168.60.0/24"
  oc_database_2 = "192.168.70.0/24" 
}

subnet_availability_zones = {
  oc_public_1 = "ap-south-1a"
  oc_public_2 = "ap-south-1b"
  oc_private_1 = "ap-south-1a"
  oc_private_2 = "ap-south-1b"
  oc_database_1 = "ap-south-1a"
  oc_database_2 = "ap-south-1b"  
}


subnet_tags = {
  oc_public_1 = {
    Name = "oc_public_1"
  },
  oc_public_2 = {
    Name = "oc_public_2"
  },
  oc_private_1 = {
    Name = "oc_private_1"
  },
  oc_private_2 = {
    Name = "oc_private_2"
  },
  oc_database_1 = {
    Name = "oc_database_1"
  },
  oc_database_2 = {
    Name = "oc_database_2"
  }
}

internet_gateway_tags = {
  Name = "oc"
}

public_route_table_tags = {
  Name = "oc_public"
}

elastic_ip_ngw_tags = {
  Name = "oc_ngw"
}

nat_gateway_tags = {
  Name = "oc"
}

private_route_table_tags = {
  Name = "oc_private"
}

lb_security_group_name = "oc_lb"
lb_security_group_description = "OC - Load Balancer Security Group"

lb_security_group_tags = {
  Name = "oc_lb"
}

bastion_security_group_name = "oc_bastion"
bastion_security_group_description = "OC - Bastion Security Group"

bastion_security_group_tags = {
  Name = "oc_bastion"
}

# Enter your public IP address.
allowed_cidr_blocks = ["x.x.x.x/x"]

app_security_group_name = "oc_app"
app_security_group_description = "OC - Application Security Group"

app_security_group_tags = {
  Name = "oc_app"
}

efs_security_group_name = "oc_efs"
efs_security_group_description = "OC - EFS Security Group"

efs_security_group_tags = {
  Name = "oc_efs"
}

database_security_group_name = "oc_database"
database_security_group_description = "OC - Database Security Group"

database_security_group_tags = {
  Name = "oc_database"
}

elk_security_group_name = "oc_elk"
elk_security_group_description = "OC - Elastic Stack Security Group"

elk_security_group_tags = {
  Name = "oc_elk"
}

db_subnet_group_name = "oc"
db_subnet_group_description = "OC - Database Subnet group"

db_subnet_group_tags = {
  Name = "oc"
}

db_parameter_group_name = "oc"
db_parameter_group_description = "OC - Database Parameter group"
db_parameter_group_family = "mariadb10.3"

# Some values are set according to recommendations from Owncloud.
# Refer to Owncloud documentation for more details.

db_parameter_group_parameters = [
  { name = "max_allowed_packet", value = 134217728, apply_method = "immediate" },
  { name = "innodb_log_file_size", value = 67108864, apply_method = "pending-reboot" },
  { name = "slow_query_log", value = 1, apply_method = "immediate" },
  { name = "log_output", value = "FILE", apply_method = "immediate" }
]

db_parameter_group_tags = {
  Name = "oc"
}

# Change the database values.
# Some variables like db_name and username cannot have special characters.
# Refer to AWS documentation for more details.

db_instance = {
  allocated_storage = 20
  max_allocated_storage = 25
  storage_type = "gp2"
  storage_encrypted = false
   
  instance_class = "db.t2.micro"
  engine = "mariadb"
  engine_version = 10.3
  
  identifier = "enter-instance-name"
  db_name = "databasename"
  username = "databaseusername"
  password = "enter-database-password"

  multi_az = false
  
  backup_retention_period = 7
  backup_window = "20:30-21:00"
  copy_tags_to_snapshot = true
  maintenance_window = "Wed:21:30-Wed:22:00"
  auto_minor_version_upgrade = true
  
  delete_automated_backups = true
  skip_final_snapshot = true
  final_snapshot_identifier = "enter-snapshot-name" 
  deletion_protection = false
}

enabled_cloudwatch_logs_exports = ["error", "slowquery"]

db_instance_tags = {
  Name = "oc"
}

key_name = "oc"

# Enter the path to your SSH public key.
path_to_public_key = "/home/ubuntu/.ssh/id_rsa.pub"

key_pair_tags = {
  Name = "oc"
}


# The Amazon Machine Image (AMI) being used is Ubuntu 18.04.5 LTS.
bastion_launch_template = {
  name = "oc_bastion"
  description = "OC - Lauch Template for Bastion"
  image_id = "ami-04bde106886a53080"
  instance_type = "t2.micro"  
  encrypted = true
  volume_size = 15
  volume_type = "standard"
  delete_on_termination = true  
}

bastion_instance_tags = {
  Name = "oc_bastion"
}

bastion_autoscaling_group = {
  name = "oc_bastion"
  desired_capacity = 1
  min_size = 1
  max_size = 1  
}

bastion_login_user = "ubuntu"

# The Amazon Machine Image (AMI) being used is Ubuntu 18.04.5 LTS.
k8s_master = {
  ami = "ami-04bde106886a53080"
  instance_type = "t3a.medium"
  
  volume_size = 15
  volume_type = "gp3"
  encrypted = true  
  delete_on_termination = true
  
  cpu_credits = "standard"
}

k8s_master_tags = {
    Name = "oc_k8s_master"
}

# The Amazon Machine Image (AMI) being used is Ubuntu 18.04.5 LTS.
k8s_worker = {
  ami = "ami-04bde106886a53080"
  instance_type = "t3a.medium"
  
  volume_size = 15
  volume_type = "gp3"
  encrypted = true  
  delete_on_termination = true
  
  cpu_credits = "standard"
}

k8s_worker_tags = {
    Name = "oc_k8s_worker"
}

k8s_instance_login_user = "ubuntu"

lb_name = "oc"

lb_tags = {
  Name = "oc"
}

lb_target_group_name = "oc"

lb_target_group_tags = {
  Name = "oc"
}

efs_file_system = {
  encrypted = true
  transition_to_ia = "AFTER_30_DAYS"
  transition_to_primary_storage_class = "AFTER_1_ACCESS"
  automatic_backups = "ENABLED"
}

efs_file_system_tags = {
  Name = "oc"
}

# The Amazon Machine Image (AMI) being used is Ubuntu 18.04.5 LTS.
elk = {
  ami = "ami-04bde106886a53080"
  instance_type = "t3a.medium"
  
  volume_size = 15
  volume_type = "gp3"
  encrypted = true  
  delete_on_termination = true
  
  cpu_credits = "standard"
}

elk_tags = {
  Name = "oc_elk"
}

elk_instance_login_user = "ubuntu"

# Enter your domain name.
domain_name = "example.com"

# Email address is used by Certbot - Let's Encrypt.
email_address = "user@example.com"

# Enter the delegation_set_id received from the output of "aws route53 create-reusable-delegation-set" command.
delegation_set_id = "ABCD1234EFGH5678"

public_hosted_zone_description = "oc_public"

public_hosted_zone_tags = {
  Name = "oc_public"
} 

private_hosted_zone_description = "oc_private"

private_hosted_zone_tags = {
  Name = "oc_private"
}

iam_policy_route53 = {
  name = "oc_route53"
  description = "Allows Route 53 access."
}

iam_policy_route53_tags = {
  Name = "oc_route53"
}

iam_policy_acm = {
  name = "oc_acm"
  description = "Allows ACM access."  
}

iam_policy_acm_tags = {
  Name = "oc_acm"
}

iam_role_ec2_route53 = {
  name = "oc_ec2_route53"
  description = "Allows EC2 to access Route 53."
}

iam_role_ec2_route53_tags = {
  Name = "oc_ec2_route53"
}

iam_role_ec2_route53_acm = {
  name = "oc_ec2_route53_acm"
  description = "Allows EC2 to access Route 53 and ACM." 
}

iam_role_ec2_route53_acm_tags = {
  Name = "oc_ec2_route53_acm"
}

instance_profile_route53_name = "oc_route53"

instance_profile_route53_tags = {
  Name = "oc_route53"
}

instance_profile_route53_acm_name = "oc_route53_acm"

instance_profile_route53_acm_tags = {
  Name = "oc_route53_acm"
}

# Change Owncloud admin details.
# These will be used to login on the owncloud website.
owncloud_admin_username = "enter-owncloud-admin-username"
owncloud_admin_password = "enter-owncloud-admin-password"
