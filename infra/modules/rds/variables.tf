variable "project" {
  description = "Nome do projeto"
  type        = string
}

variable "private_subnet_ids" {
  description = "IDs das subnets privadas para o DB Subnet Group"
  type        = list(string)
}

variable "security_group_id" {
  description = "ID do Security Group do RDS"
  type        = string
}

variable "db_name" {
  description = "Nome do banco de dados"
  type        = string
  default     = "reservas"
}

variable "db_user" {
  description = "Usuário master do banco de dados"
  type        = string
  default     = "postgres"
}

variable "db_password" {
  description = "Senha master do banco de dados"
  type        = string
  sensitive   = true
}

variable "tags" {
  description = "Tags comuns a todos os recursos"
  type        = map(string)
  default     = {}
}
