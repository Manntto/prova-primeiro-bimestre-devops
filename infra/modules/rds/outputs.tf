output "endpoint" {
  description = "Endpoint de conexão do RDS (host:port)"
  value       = aws_db_instance.postgres.endpoint
}

output "host" {
  description = "Host do RDS (sem porta)"
  value       = aws_db_instance.postgres.address
}

output "port" {
  description = "Porta do RDS"
  value       = aws_db_instance.postgres.port
}

output "db_name" {
  description = "Nome do banco de dados"
  value       = aws_db_instance.postgres.db_name
}
