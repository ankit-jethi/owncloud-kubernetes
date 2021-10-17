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
