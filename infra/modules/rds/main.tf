# ─── DB Subnet Group — subnets privadas em 2 AZs ─────────────────────────────

resource "aws_db_subnet_group" "main" {
  name        = "${var.project}-db-subnet-group"
  subnet_ids  = var.private_subnet_ids
  description = "Subnet group para RDS PostgreSQL nas subnets privadas"

  tags = merge(var.tags, { Name = "${var.project}-db-subnet-group" })
}

# ─── RDS PostgreSQL ───────────────────────────────────────────────────────────

resource "aws_db_instance" "postgres" {
  identifier        = "${var.project}-rds"
  engine            = "postgres"
  engine_version    = "15"
  instance_class    = "db.t3.micro"
  allocated_storage = 20
  storage_type      = "gp2"

  db_name  = var.db_name
  username = var.db_user
  password = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [var.security_group_id]

  # Requisitos obrigatórios da prova
  publicly_accessible = false
  storage_encrypted   = true

  # Configurações para o Learner Lab (evita custos e restrições)
  multi_az                = false
  skip_final_snapshot     = true
  deletion_protection     = false
  backup_retention_period = 0

  tags = merge(var.tags, { Name = "${var.project}-rds" })
}
