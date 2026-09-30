variable "project" {
  description = "Nome do projeto — usado como prefixo em todos os recursos"
  type        = string
  default     = "reservas"
}

variable "db_password" {
  description = "Senha do banco de dados RDS"
  type        = string
  sensitive   = true
}

variable "db_name" {
  description = "Nome do banco de dados"
  type        = string
  default     = "reservas"
}

variable "db_user" {
  description = "Usuário master do banco"
  type        = string
  default     = "postgres"
}

variable "tags" {
  description = "Tags comuns a todos os recursos AWS"
  type        = map(string)
  default = {
    Projeto   = "prova-primeiro-bimestre"
    Aluno     = "Matheus Mantovani"
    RA        = "1120245"
    ManagedBy = "terraform"
  }
}
