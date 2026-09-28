# Evidências

Esta pasta reúne os outputs capturados durante o desenvolvimento e validação da solução.

## docker-build.txt
Output completo do `docker build` da imagem `api-reservas:1.0`.
Gerado com: `docker build -t api-reservas:1.0 ./app`

## compose-ps.txt
Output do `docker compose ps` com os dois containers rodando.
Gerado com: `docker compose up --build -d && docker compose ps`
Mostra ambos os serviços (`reservas-api` e `reservas-db`) com status `Up (healthy)`.

## terraform-plan.txt
*(a ser gerado na Etapa 6 — Terraform apply)*
Output do `terraform plan` antes do apply na AWS.
