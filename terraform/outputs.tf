output "rds_database_endpoint" {
  description = "The hostname of the RDS instance in address:port format."
  value       = aws_db_instance.oc.endpoint
}

output "database_name" {
  description = "The name of the database."
  value       = aws_db_instance.oc.name
}

output "database_username" {
  description = "The master username for the database."
  value       = aws_db_instance.oc.username
}

output "bastion_public_ip" {
  description = "Public IP address of the bastion instance."
  value       = data.aws_instance.oc_bastion.public_ip
}

output "kubernetes_master_private_ip" {
  description = "Private IP address of the K8s master instance."
  value       = aws_instance.oc_k8s_master.private_ip
}

output "kubernetes_worker_private_ip" {
  description = "Private IP address of the K8s worker instance."
  value       = aws_instance.oc_k8s_worker.private_ip
}

output "load_balancer_dns_name" {
  description = "DNS name of the Load Balancer."
  value       = aws_lb.oc.dns_name
}

output "efs_dns_name" {
  description = "DNS name of the Elastic File System (EFS)."
  value       = aws_efs_file_system.oc.dns_name
}

output "efs_size_in_bytes" {
  description = "The latest known metered size (in bytes) of data stored in the file system."
  value       = aws_efs_file_system.oc.size_in_bytes
}

output "elk_instance_public_ip" {
  description = "Public IP address of the Elastic Stack instance."
  value       = aws_instance.oc_elk.public_ip
}

output "elk_instance_private_ip" {
  description = "Private IP address of the Elastic Stack instance."
  value       = aws_instance.oc_elk.private_ip
}

output "owncloud_app_url" {
  description = "URL to access Owncloud application."
  value       = aws_route53_record.oc_app_1.fqdn
}

output "kibana_url" {
  description = "URL to access Kibana."
  value       = aws_route53_record.oc_kibana_1.fqdn
}

output "bastion_hostname" {
  description = "Hostname of the bastion instance."
  value       = aws_route53_record.oc_bastion.fqdn
}

output "database_hostname" {
  description = "Hostname of the database instance."
  value       = aws_route53_record.oc_database.fqdn
}
