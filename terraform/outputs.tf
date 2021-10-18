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
