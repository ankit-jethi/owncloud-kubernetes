output "db_hostname" {
  description = "The hostname of the RDS instance in address:port format."
  value = aws_db_instance.oc.endpoint
}

output "db_name" {
  description = "The name of the database."
  value = aws_db_instance.oc.name
}

output "db_username" {
  description = "The master username for the database."
  value = aws_db_instance.oc.username
}

output "bastion_instance_public_ip" {
  description = "Public IP address of the bastion instance."
  value = data.aws_instance.oc_bastion.public_ip
}

output "k8s_master_private_ip" {
  description = "Private IP address of the K8s master instance."
  value = aws_instance.oc_k8s_master.private_ip
}

output "k8s_worker_private_ip" {
  description = "Private IP address of the K8s worker instance."
  value = aws_instance.oc_k8s_worker.private_ip
}

output "lb_dns_name" {
  description = "DNS name of the Load Balancer."
  value = aws_lb.oc.dns_name
}

output "efs_dns_name" {
  description = "DNS name of the EFS filesystem."
  value = aws_efs_file_system.oc.dns_name
}

output "efs_size_in_bytes" {
  description = "The latest known metered size (in bytes) of data stored in the file system."
  value = aws_efs_file_system.oc.size_in_bytes
}

