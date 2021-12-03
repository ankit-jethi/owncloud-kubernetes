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
  app_security_group_ingress = [
    { description = "App access from the the internet.", protocol = "tcp", port = 30000, security_groups = [], cidr_blocks = ["0.0.0.0/0"], self = false },
    { description = "SSH access from the Bastion.", protocol = "tcp", port = 22, security_groups = [aws_security_group.oc_bastion.id], cidr_blocks = [], self = false },
    { description = "Kubernetes API server", protocol = "tcp", port = 6443, security_groups = [], cidr_blocks = [], self = true },
    { description = "etcd server client API", protocol = "tcp", port = 2379, security_groups = [], cidr_blocks = [], self = true },
    { description = "etcd server client API", protocol = "tcp", port = 2380, security_groups = [], cidr_blocks = [], self = true },
    { description = "Kubelet API", protocol = "tcp", port = 10250, security_groups = [], cidr_blocks = [], self = true },
    { description = "kube-scheduler", protocol = "tcp", port = 10259, security_groups = [], cidr_blocks = [], self = true },
    { description = "kube-controller-manager", protocol = "tcp", port = 10257, security_groups = [], cidr_blocks = [], self = true },
    { description = "Flannel pod network", protocol = "udp", port = 8472, security_groups = [], cidr_blocks = [], self = true }    
  ]
  
  elk_security_group_ingress = [
    { description = "SSH access from your IP address(es).", port = 22, security_groups = [], cidr_blocks = var.allowed_cidr_blocks_ssh },
    { description = "Elasticsearch - Beats", port = 9200, security_groups = [aws_security_group.oc_app.id, aws_security_group.oc_bastion.id], cidr_blocks = [] },
    { description = "Kibana - Beats", port = 5601, security_groups = [aws_security_group.oc_app.id, aws_security_group.oc_bastion.id], cidr_blocks = [] },
    { description = "Kibana - HTTP", port = 80, security_groups = [], cidr_blocks = var.allowed_cidr_blocks_ssh },
    { description = "Kibana - HTTPS", port = 443, security_groups = [], cidr_blocks = var.allowed_cidr_blocks_ssh }
  ]
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
      cidr_blocks = var.allowed_cidr_blocks_ssh
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
      protocol = ingress.value.protocol
      security_groups = ingress.value.security_groups
      self = ingress.value.self
      cidr_blocks = ingress.value.cidr_blocks
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

resource "aws_security_group" "oc_efs" {
  name = var.efs_security_group_name
  description = var.efs_security_group_description
  vpc_id = aws_vpc.oc.id

  ingress {
      description = "EFS access from the app servers."
      from_port = 2049
      to_port = 2049
      protocol = "tcp"
      security_groups = [aws_security_group.oc_app.id]
  }
  
  egress {
      description = "Allow all outbound traffic."  
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }  

  tags = var.efs_security_group_tags
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

resource "aws_security_group" "oc_elk" {
  name = var.elk_security_group_name
  description = var.elk_security_group_description
  vpc_id = aws_vpc.oc.id
  
  dynamic "ingress" {
    for_each = local.elk_security_group_ingress
    
    content {
      description = ingress.value.description
      from_port = ingress.value.port
      to_port = ingress.value.port
      protocol = "tcp"
      security_groups = ingress.value.security_groups
      cidr_blocks = ingress.value.cidr_blocks
    }
  }
  
  egress {
      description = "Allow all outbound traffic."  
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }  
  
  tags = var.elk_security_group_tags
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
  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports
  
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

data "aws_instance" "oc_bastion" {
  instance_tags = var.bastion_instance_tags
  
  depends_on = [aws_autoscaling_group.oc_bastion]  
}

resource "null_resource" "oc_bastion" {

  provisioner "local-exec" {
    working_dir = "../group_vars"
    command = <<-EOT
    cat > k8s.yml <<EOF
    ansible_ssh_common_args: '-o StrictHostKeyChecking=no -o ProxyCommand="ssh -o StrictHostKeyChecking=no -W %h:%p -q ${var.bastion_login_user}@${data.aws_instance.oc_bastion.public_ip}"'
    EOF
    EOT
  }

  triggers = {
    bastion_instance_public_ip = data.aws_instance.oc_bastion.public_ip
  }
}

resource "aws_instance" "oc_k8s_master" {
  ami = var.k8s_master["ami"]
  instance_type = var.k8s_master["instance_type"]
  key_name = aws_key_pair.oc.id
  subnet_id = aws_subnet.oc_private_1.id
  vpc_security_group_ids = [aws_security_group.oc_app.id]
  
  root_block_device {
    volume_size = var.k8s_master["volume_size"]
    volume_type = var.k8s_master["volume_type"]
    encrypted = var.k8s_master["encrypted"]
    delete_on_termination = var.k8s_master["delete_on_termination"]
  }
  
  credit_specification {
    cpu_credits = var.k8s_master["cpu_credits"]
  }
  
  tags = var.k8s_master_tags
  volume_tags = var.k8s_master_tags
}

resource "aws_instance" "oc_k8s_worker" {
  ami = var.k8s_worker["ami"]
  instance_type = var.k8s_worker["instance_type"]
  key_name = aws_key_pair.oc.id
  subnet_id = aws_subnet.oc_private_2.id
  vpc_security_group_ids = [aws_security_group.oc_app.id]
  
  root_block_device {
    volume_size = var.k8s_worker["volume_size"]
    volume_type = var.k8s_worker["volume_type"]
    encrypted = var.k8s_worker["encrypted"]
    delete_on_termination = var.k8s_worker["delete_on_termination"]
  }
  
  credit_specification {
    cpu_credits = var.k8s_worker["cpu_credits"]
  }
  
  tags = var.k8s_worker_tags
  volume_tags = var.k8s_worker_tags
}

resource "aws_lb_target_group" "oc" {
  name = var.lb_target_group_name
  protocol = "TCP"
  port = 30000
  preserve_client_ip = true
  target_type = "instance"
  vpc_id = aws_vpc.oc.id

  stickiness {
    enabled = true
    type = "source_ip"
  }
  
  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    interval = 10
    protocol = "TCP"
    port = "traffic-port"
  }
  
  tags = var.lb_target_group_tags
}

resource "aws_lb_target_group_attachment" "oc" {
  for_each = {
    oc_k8s_master = aws_instance.oc_k8s_master.id
    oc_k8s_worker = aws_instance.oc_k8s_worker.id
  }

  target_group_arn = aws_lb_target_group.oc.arn
  target_id = each.value
}

resource "aws_lb" "oc" {
  name = var.lb_name
  internal = false
  load_balancer_type = "network"
  subnets = [aws_subnet.oc_public_1.id, aws_subnet.oc_public_2.id]
  ip_address_type = "ipv4"
  
  tags = var.lb_tags
}

resource "aws_lb_listener" "oc_http" {
  load_balancer_arn = aws_lb.oc.arn
  protocol = "TCP"
  port = 80
  
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.oc.arn
  }
}

resource "aws_efs_file_system" "oc" {
  encrypted = var.efs_file_system["encrypted"]
  
  lifecycle_policy {
    transition_to_ia = var.efs_file_system["transition_to_ia"]
  }
  
  lifecycle_policy {
    transition_to_primary_storage_class = var.efs_file_system["transition_to_primary_storage_class"]
  }  
  
  tags = var.efs_file_system_tags
}

resource "aws_efs_backup_policy" "oc" {
  file_system_id = aws_efs_file_system.oc.id
  
  backup_policy {
    status = var.efs_file_system["automatic_backups"]
  }
}

resource "aws_efs_mount_target" "oc_private" {
  for_each = {
    oc_private_1 = aws_subnet.oc_private_1.id
    oc_private_2 = aws_subnet.oc_private_2.id
  }

  file_system_id = aws_efs_file_system.oc.id
  subnet_id = each.value
  security_groups = [aws_security_group.oc_efs.id]
}

resource "aws_instance" "oc_elk" {
  ami = var.elk["ami"]
  instance_type = var.elk["instance_type"]
  key_name = aws_key_pair.oc.id
  subnet_id = aws_subnet.oc_public_2.id
  vpc_security_group_ids = [aws_security_group.oc_elk.id]
  iam_instance_profile = aws_iam_instance_profile.oc_ec2_route53.name
  
  root_block_device {
    volume_size = var.elk["volume_size"]
    volume_type = var.elk["volume_type"]
    encrypted = var.elk["encrypted"]
    delete_on_termination = var.elk["delete_on_termination"]
  }
  
  credit_specification {
    cpu_credits = var.elk["cpu_credits"]
  }
  
  tags = var.elk_tags
  volume_tags = var.elk_tags
}

resource "null_resource" "oc_ansible_setup" {

  provisioner "local-exec" {
    working_dir = "../"
    command = <<-EOT
    cat > aws_inventory <<EOF
    [master]
    ${aws_instance.oc_k8s_master.private_ip} ansible_user=${var.k8s_instance_login_user}
    
    [worker]
    ${aws_instance.oc_k8s_worker.private_ip} ansible_user=${var.k8s_instance_login_user}
    
    [k8s:children]
    master
    worker
    
    [bastion]
    ${data.aws_instance.oc_bastion.public_ip} ansible_user=${var.bastion_login_user}
    
    [elk]
    ${aws_instance.oc_elk.public_ip} ansible_user=${var.elk_instance_login_user}
    
    EOF
    EOT
  }

  provisioner "local-exec" {
    working_dir = "../group_vars"
    command = <<-EOT
    sed -i 's/^admin_user.*/admin_user: "${var.k8s_instance_login_user}"/' all.yml && \
    sed -i 's/^aws_efs_dns_name.*/aws_efs_dns_name: "${aws_efs_file_system.oc.dns_name}"/' all.yml && \
    sed -i 's/^apiserver_advertise_address.*/apiserver_advertise_address: "${aws_instance.oc_k8s_master.private_ip}"/' all.yml && \
    sed -i 's/^kibana_host.*/kibana_host: "${aws_instance.oc_elk.private_ip}:5601"/' all.yml && \
    sed -i 's/^elasticsearch_host.*/elasticsearch_host: "${aws_instance.oc_elk.private_ip}:9200"/' all.yml && \
    sed -i 's/^k8s_master_private_ip.*/k8s_master_private_ip: "${aws_instance.oc_k8s_master.private_ip}"/' all.yml && \
    sed -i 's/^k8s_worker_private_ip.*/k8s_worker_private_ip: "${aws_instance.oc_k8s_worker.private_ip}"/' all.yml && \
    sed -i 's/^kibana_domain.*/kibana_domain: "kibana.${var.domain_name}"/' all.yml && \
    sed -i 's/^email_for_lets_encrypt.*/email_for_lets_encrypt: "${var.email_address}"/' all.yml
    EOT
  }    
  
  triggers = {
    k8s_master_private_ip = aws_instance.oc_k8s_master.private_ip
    k8s_worker_private_ip = aws_instance.oc_k8s_worker.private_ip
    bastion_instance_public_ip = data.aws_instance.oc_bastion.public_ip
    elk_instance_public_ip = aws_instance.oc_elk.public_ip
    aws_efs_dns_name = aws_efs_file_system.oc.dns_name
  }
}

resource "null_resource" "oc_k8s_and_elk" {

  provisioner "local-exec" {
    working_dir = "../"
    command = <<-EOT
    aws ec2 wait instance-status-ok --instance-ids ${aws_instance.oc_k8s_master.id} ${aws_instance.oc_k8s_worker.id} && \
    ansible-playbook --inventory aws_inventory --skip-tags "always" --tags "setup-k8s" --verbose site.yml && \
    aws ec2 wait instance-status-ok --instance-ids ${aws_instance.oc_elk.id} ${data.aws_instance.oc_bastion.id} && \
    ansible-playbook --inventory aws_inventory --tags "elastic-stack-nginx,beats" --verbose site.yml
    EOT
  } 

  triggers = {
    k8s_master_id = aws_instance.oc_k8s_master.id
    k8s_worker_id = aws_instance.oc_k8s_worker.id
    elk_instance_id = aws_instance.oc_elk.id
    bastion_instance_id = data.aws_instance.oc_bastion.id
  }
  
  depends_on = [null_resource.oc_ansible_setup, null_resource.oc_bastion]
}

resource "null_resource" "oc_deploy_owncloud" {

  provisioner "local-exec" {
    working_dir = "../roles/owncloud/templates/"
    command = <<-EOT
    sed -i 's/owncloud-domain.*/owncloud-domain: "${var.domain_name}"/' 04-config-map.yml && \
    sed -i 's/owncloud-db-host.*/owncloud-db-host: "${aws_route53_record.oc_database.fqdn}"/' 04-config-map.yml
    EOT
  }

  provisioner "local-exec" {
    working_dir = "../"
    command = <<-EOT
    aws rds wait db-instance-available --db-instance-identifier ${aws_db_instance.oc.identifier} && \
    ansible-playbook --inventory aws_inventory --skip-tags "always" --tags "deploy-app" --verbose site.yml
    EOT
  }

  triggers = {
    k8s_and_elk_id = null_resource.oc_k8s_and_elk.id
    aws_efs_dns_name = aws_efs_file_system.oc.dns_name
    db_instance_id = aws_db_instance.oc.id    
  }
  
  depends_on = [null_resource.oc_k8s_and_elk, aws_efs_mount_target.oc_private]
}


resource "aws_iam_role" "oc_ec2_route53" {
  name = var.iam_role["name"]
  description = var.iam_role["description"]

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  inline_policy {
    name = var.iam_role["policy_name"]
    policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "route53:ListHostedZones",
                "route53:GetChange"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "route53:ChangeResourceRecordSets"
            ],
            "Resource": [
                "arn:aws:route53:::hostedzone/${aws_route53_zone.oc_public.zone_id}"
            ]
        }
    ]
}
EOF
  }

  tags = var.iam_role_tags
}

resource "aws_iam_instance_profile" "oc_ec2_route53" {
  name = var.instance_profile_name
  role = aws_iam_role.oc_ec2_route53.name
  
  tags = var.instance_profile_tags  
}

resource "aws_route53_zone" "oc_public" {
  name = var.domain_name
  comment = var.public_hosted_zone_description
  delegation_set_id = var.delegation_set_id
  force_destroy = true
  
  tags = var.public_hosted_zone_tags  
}

resource "aws_route53_record" "oc_app_1" {
  zone_id = aws_route53_zone.oc_public.zone_id
  name = ""
  type = "A"
  
  alias {
    name = aws_lb.oc.dns_name
    zone_id = aws_lb.oc.zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "oc_app_2" {
  zone_id = aws_route53_zone.oc_public.zone_id
  name = "www.${var.domain_name}"
  type = "CNAME"
  ttl = "10"
  records = [var.domain_name]
}

resource "aws_route53_record" "oc_kibana_1" {
  zone_id = aws_route53_zone.oc_public.zone_id
  name = "kibana.${var.domain_name}"
  type = "A"
  ttl = "10"
  records = [aws_instance.oc_elk.public_ip]
}

resource "aws_route53_record" "oc_kibana_2" {
  zone_id = aws_route53_zone.oc_public.zone_id
  name = "www.kibana.${var.domain_name}"
  type = "CNAME"
  ttl = "10"
  records = ["kibana.${var.domain_name}"]
}

resource "aws_route53_record" "oc_bastion" {
  zone_id = aws_route53_zone.oc_public.zone_id
  name = "bastion.${var.domain_name}"
  type = "A"
  ttl = "10"
  records = [data.aws_instance.oc_bastion.public_ip]
}

resource "aws_route53_zone" "oc_private" {
  name = var.domain_name
  comment = var.private_hosted_zone_description
  force_destroy = true
  
  vpc {
    vpc_id = aws_vpc.oc.id
  }
  
  tags = var.private_hosted_zone_tags 
}

resource "aws_route53_record" "oc_database" {
  zone_id = aws_route53_zone.oc_private.zone_id
  name = "database.${var.domain_name}"
  type = "CNAME"
  ttl = "10"
  records = [aws_db_instance.oc.address]  
}
