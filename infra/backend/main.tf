# ─────────────────────────────────────────────────────────────────────────────
# NOTA: O bucket S3 "tfstate-reservas-1120245" foi provisionado via AWS CLI
# pois o AWS Academy Learner Lab bloqueia s3:GetBucketObjectLockConfiguration
# via SCP organizacional, impedindo que o provider Terraform 5.x gerencie
# o recurso aws_s3_bucket diretamente.
#
# Configurações aplicadas via CLI (evidência nos outputs abaixo):
#   - Versionamento: Enabled
#   - Encriptação: AES256 (SSE-S3)
#   - Acesso público: bloqueado
#
# Referência: https://developer.hashicorp.com/terraform/language/backend/s3
# ─────────────────────────────────────────────────────────────────────────────

# ─── DynamoDB — State Locking ─────────────────────────────────────────────────

resource "aws_dynamodb_table" "terraform_lock" {
  name         = "tflock-reservas-1120245"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name      = "tflock-reservas-1120245"
    Projeto   = "prova-primeiro-bimestre"
    Aluno     = "Matheus Mantovani"
    RA        = "1120245"
    ManagedBy = "terraform"
  }
}

# ─── Outputs ──────────────────────────────────────────────────────────────────

output "bucket_name" {
  description = "Nome do bucket S3 para remote state (provisionado via CLI)"
  value       = "tfstate-reservas-1120245"
}

output "dynamodb_table" {
  description = "Nome da tabela DynamoDB para state locking"
  value       = aws_dynamodb_table.terraform_lock.name
}
