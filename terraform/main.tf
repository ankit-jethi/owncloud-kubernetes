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

resource "aws_subnet" "oc_database_1" {
  vpc_id = aws_vpc.oc.id
  cidr_block = var.subnet_cidr_blocks["oc_database_1"]
  availability_zone = var.subnet_availability_zones["oc_database_1"]
  
  tags = var.subnet_tags["oc_database_1"]
}

resource "aws_subnet" "oc_database_2" {
  vpc_id = aws_vpc.oc.id
  cidr_block = var.subnet_cidr_blocks["oc_database_2"]
  availability_zone = var.subnet_availability_zones["oc_database_2"]
  
  tags = var.subnet_tags["oc_database_2"]
}

resource "aws_internet_gateway" "oc" {
  vpc_id = aws_vpc.oc.id
  
  tags = var.internet_gateway_tags
}


resource "aws_route_table" "oc_public" {
  vpc_id = aws_vpc.oc.id
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.oc.id
  }
  
  tags = var.public_route_table_tags
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
  
  tags = var.elastic_ip_ngw_tags
  
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

locals {
  lb_security_group_ingress = [
    { description = "HTTP access from the world.", port = 80 },
    { description = "HTTPS access from the world.", port = 443 }
  ]
  
  app_security_group_ingress = [
    { description = "HTTP access from the Load Balancer", port = 80, security_groups = [aws_security_group.oc_lb.id] },
    { description = "SSH access from the Bastion.", port = 22, security_groups = [aws_security_group.oc_bastion.id] }
  ]
}

resource "aws_security_group" "oc_lb" {
  name = var.lb_security_group_name
  description = var.lb_security_group_description
  vpc_id = aws_vpc.oc.id
  
  dynamic "ingress" {
    for_each = local.lb_security_group_ingress
    
    content {
      description = ingress.value.description
      from_port = ingress.value.port
      to_port = ingress.value.port
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]      
    }
  }
  
  egress {
      description = "Allow all outbound traffic."  
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }  
  
  tags = var.lb_security_group_tags
}

resource "aws_security_group" "oc_bastion" {
  name = var.bastion_security_group_name
  description = var.bastion_security_group_description
  vpc_id = aws_vpc.oc.id
  
  ingress {
      description = "SSH access from your IP address(es)."
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = var.cidr_blocks_ssh_bastion
  }
  
  egress {
      description = "Allow all outbound traffic."  
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
    
  tags = var.bastion_security_group_tags    
}

resource "aws_security_group" "oc_app" {
  name = var.app_security_group_name
  description = var.app_security_group_description
  vpc_id = aws_vpc.oc.id
  
  dynamic "ingress" {
    for_each = local.app_security_group_ingress
    
    content {
      description = ingress.value.description
      from_port = ingress.value.port
      to_port = ingress.value.port
      protocol = "tcp"
      security_groups = ingress.value.security_groups    
    }
  }
  
  egress {
      description = "Allow all outbound traffic."  
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }  
  
  tags = var.app_security_group_tags
}

resource "aws_security_group" "oc_database" {
  name = var.database_security_group_name
  description = var.database_security_group_description
  vpc_id = aws_vpc.oc.id
  
  ingress {
      description = "Database access from the app and bastion servers."
      from_port = 3306
      to_port = 3306
      protocol = "tcp"
      security_groups = [aws_security_group.oc_app.id, aws_security_group.oc_bastion.id]
  }
    
  tags = var.database_security_group_tags    
}

resource "aws_db_subnet_group" "oc" {
  name = var.db_subnet_group_name
  description = var.db_subnet_group_description
  subnet_ids = [aws_subnet.oc_database_1.id, aws_subnet.oc_database_2.id]
  
  tags = var.db_subnet_group_tags
}

resource "aws_db_parameter_group" "oc" {
  name = var.db_parameter_group_name
  description = var.db_parameter_group_description
  family = var.db_parameter_group_family
  
  dynamic "parameter" {
    for_each = var.db_parameter_group_parameters
    
    content {
      name = parameter.value.name
      value = parameter.value.value
      apply_method = parameter.value.apply_method
    }
  }
  
  tags = var.db_parameter_group_tags
}

resource "aws_db_instance" "oc" {
  allocated_storage = var.db_instance["allocated_storage"]
  max_allocated_storage = var.db_instance["max_allocated_storage"]
  storage_type = var.db_instance["storage_type"]
  storage_encrypted = var.db_instance["storage_encrypted"]
   
  instance_class = var.db_instance["instance_class"]
  engine = var.db_instance["engine"]
  engine_version = var.db_instance["engine_version"]
  identifier = var.db_instance["identifier"]
  name = var.db_instance["db_name"]
  username = var.db_instance["username"]
  password = var.db_instance["password"]

  db_subnet_group_name = aws_db_subnet_group.oc.id
  multi_az = var.db_instance["multi_az"]
  vpc_security_group_ids = [aws_security_group.oc_database.id]
  parameter_group_name = aws_db_parameter_group.oc.id
  
  backup_retention_period = var.db_instance["backup_retention_period"]
  backup_window = var.db_instance["backup_window"]
  copy_tags_to_snapshot = var.db_instance["copy_tags_to_snapshot"]  
  maintenance_window = var.db_instance["maintenance_window"]
  auto_minor_version_upgrade = var.db_instance["auto_minor_version_upgrade"]
  
  delete_automated_backups = var.db_instance["delete_automated_backups"]
  skip_final_snapshot = var.db_instance["skip_final_snapshot"]
  final_snapshot_identifier = var.db_instance["final_snapshot_identifier"]  
  deletion_protection = var.db_instance["deletion_protection"]
  
  tags = var.db_instance_tags
}

resource "aws_key_pair" "oc" {
  key_name = var.key_name
  public_key = file(var.path_to_public_key)
  
  tags = var.key_pair_tags
}

resource "aws_launch_template" "oc_bastion" {
  name = var.bastion_launch_template["name"]
  description = var.bastion_launch_template["description"]
  image_id = var.bastion_launch_template["image_id"]
  instance_type = var.bastion_launch_template["instance_type"]
  key_name = aws_key_pair.oc.id
  vpc_security_group_ids = [aws_security_group.oc_bastion.id]
  
  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      encrypted = var.bastion_launch_template["encrypted"]
      volume_size = var.bastion_launch_template["volume_size"]
      volume_type = var.bastion_launch_template["volume_type"]
      delete_on_termination = var.bastion_launch_template["delete_on_termination"]
    }
  }
  
  tag_specifications {
    resource_type = "instance"
    
    tags = var.bastion_instance_tags
  }
  
  tag_specifications {
    resource_type = "volume"
    
    tags = var.bastion_instance_tags
  }  
}

resource "aws_autoscaling_group" "oc_bastion" {
  name = var.bastion_autoscaling_group["name"]
  desired_capacity = var.bastion_autoscaling_group["desired_capacity"]
  min_size = var.bastion_autoscaling_group["min_size"]
  max_size = var.bastion_autoscaling_group["max_size"]
  health_check_type = "EC2"
  vpc_zone_identifier = [aws_subnet.oc_public_1.id, aws_subnet.oc_public_2.id]
  
  launch_template {
    id = aws_launch_template.oc_bastion.id
    version = aws_launch_template.oc_bastion.latest_version
  }
}
