# ─── Módulo VPC ───────────────────────────────────────────────────────────────

module "vpc" {
  source = "./modules/vpc"

  project              = var.project
  vpc_cidr             = "10.0.0.0/16"
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.10.0/24", "10.0.11.0/24"]
  availability_zones   = ["us-east-1a", "us-east-1b"]
  tags                 = var.tags
}

# ─── Módulo Security Group ────────────────────────────────────────────────────

module "security_group" {
  source = "./modules/security-group"

  project = var.project
  vpc_id  = module.vpc.vpc_id
  tags    = var.tags
}

# ─── Módulo RDS ───────────────────────────────────────────────────────────────

module "rds" {
  source = "./modules/rds"

  project            = var.project
  private_subnet_ids = module.vpc.private_subnet_ids
  security_group_id  = module.security_group.rds_sg_id
  db_name            = var.db_name
  db_user            = var.db_user
  db_password        = var.db_password
  tags               = var.tags
}

# ─── Módulo EC2 ───────────────────────────────────────────────────────────────
# Depende do RDS para obter o host de conexão

module "ec2" {
  source = "./modules/ec2"

  project           = var.project
  subnet_id         = module.vpc.public_subnet_ids[0]
  security_group_id = module.security_group.ec2_sg_id
  db_host           = module.rds.host
  db_port           = module.rds.port
  db_name           = var.db_name
  db_user           = var.db_user
  db_password       = var.db_password
  api_port          = 3000
  tags              = var.tags
}
