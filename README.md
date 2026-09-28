# API de Reservas — TechNova

**Aluno:** Matheus Mantovani  
**RA:** 1120245  
**Disciplina:** DevOps — 2026.2  

## Descrição

Ambiente completo e reproduzível da API de Reservas da TechNova, desenvolvido como prova do primeiro bimestre da disciplina de DevOps.

A solução cobre toda a jornada: versionamento Git, containerização com Docker, orquestração local com Docker Compose e infraestrutura na AWS com Terraform modularizado e remote state.

## Tecnologias

- **API:** Node.js + Express
- **Banco de dados:** PostgreSQL
- **Containerização:** Docker + Docker Compose
- **Infraestrutura:** Terraform (AWS — VPC, EC2, RDS, S3, DynamoDB)

## Como rodar localmente

```bash
cp .env.example .env
# edite o .env com suas credenciais
docker compose up --build
```

A API estará disponível em `http://localhost:3000`.

## Rotas da API

| Método | Rota | Descrição |
|--------|------|-----------|
| GET | /health | Health check |
| POST | /reservas | Cria uma reserva |
| GET | /reservas | Lista todas as reservas |
| GET | /reservas/:id | Busca reserva por ID |
| PUT | /reservas/:id | Atualiza uma reserva |
| DELETE | /reservas/:id | Remove uma reserva |

## Estrutura do projeto

```
.
├── app/                   # API de Reservas
│   ├── src/
│   ├── package.json
│   ├── Dockerfile
│   └── .dockerignore
├── docker-compose.yml
├── .env.example
├── infra/                 # Terraform modularizado
│   ├── modules/
│   └── ...
├── evidencias/
└── relatorio.md
```
