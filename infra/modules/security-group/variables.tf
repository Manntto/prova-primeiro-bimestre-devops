variable "project" {
  description = "Nome do projeto — usado como prefixo nos recursos"
  type        = string
}

variable "vpc_id" {
  description = "ID da VPC onde os Security Groups serão criados"
  type        = string
}

variable "tags" {
  description = "Tags comuns a todos os recursos"
  type        = map(string)
  default     = {}
}
