output "ec2_public_ip" {
  description = "IP público da EC2 com a API"
  value       = module.ec2.public_ip
}

output "ec2_public_dns" {
  description = "DNS público da EC2"
  value       = module.ec2.public_dns
}

output "api_url" {
  description = "URL da API de Reservas na AWS"
  value       = "http://${module.ec2.public_ip}:3000"
}

output "rds_endpoint" {
  description = "Endpoint completo do RDS (host:port)"
  value       = module.rds.endpoint
}

output "rds_host" {
  description = "Host do RDS"
  value       = module.rds.host
}
