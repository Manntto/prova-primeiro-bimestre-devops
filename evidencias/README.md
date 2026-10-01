# Evidências — Prova Primeiro Bimestre

## Arquivos

| Arquivo | Conteúdo |
|---------|----------|
| `docker-build.txt` | Output do `docker build` da imagem api-reservas:1.0 (multi-stage, non-root) |
| `compose-ps.txt` | Output do `docker compose ps` com os dois containers healthy |
| `git-log.txt` | Histórico Git com grafo de branches, Conventional Commits e feature branches |
| `terraform-plan.txt` | Output do `terraform plan` — 14 resources to add |
| `terraform-outputs.txt` | Outputs do `terraform apply`: IP da EC2, endpoint do RDS, URL da API |
| `api-local-test.txt` | CRUD completo da API local (Docker Compose + PostgreSQL) |
| `api-aws-test.txt` | CRUD completo da API na AWS (EC2 + RDS) |

## Resumo das Evidências

- **Git:** 13 commits, Conventional Commits, 2 feature branches com merge no main
- **Docker:** Imagem multi-stage `api-reservas:1.0`, usuário não-root (`appuser`)
- **Compose:** API + PostgreSQL healthy, porta 3000 exposta
- **Terraform:** 14 recursos (VPC, 4 subnets, IGW, route table, 2 SGs, EC2, RDS, subnet group) — `Plan: 14 to add`
- **AWS:** EC2 `98.81.51.238`, RDS `reservas-rds.ceiks7fjab1o.us-east-1.rds.amazonaws.com`
- **API local:** CRUD completo funcionando contra PostgreSQL (Docker)
- **API AWS:** CRUD completo funcionando contra RDS PostgreSQL na nuvem
