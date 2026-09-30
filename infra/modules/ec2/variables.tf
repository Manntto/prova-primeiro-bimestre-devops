variable "project" {
  description = "Nome do projeto"
  type        = string
}

variable "subnet_id" {
  description = "ID da subnet pública onde a EC2 será criada"
  type        = string
}

variable "security_group_id" {
  description = "ID do Security Group da EC2"
  type        = string
}

variable "db_host" {
  description = "Endpoint do RDS PostgreSQL"
  type        = string
}

variable "db_port" {
  description = "Porta do banco de dados"
  type        = number
  default     = 5432
}

variable "db_name" {
  description = "Nome do banco de dados"
  type        = string
}

variable "db_user" {
  description = "Usuário do banco de dados"
  type        = string
}

variable "db_password" {
  description = "Senha do banco de dados"
  type        = string
  sensitive   = true
}

variable "api_port" {
  description = "Porta em que a API vai escutar"
  type        = number
  default     = 3000
}

variable "tags" {
  description = "Tags comuns a todos os recursos"
  type        = map(string)
  default     = {}
}
