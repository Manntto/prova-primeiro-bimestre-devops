# --- Security Group: EC2 ------------------------------------------------------

resource "aws_security_group" "ec2" {
  name        = "${var.project}-sg-ec2"
  description = "Security Group da EC2 - permite SSH e porta da API"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "API Node.js"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "${var.project}-sg-ec2" })
}

# --- Security Group: RDS ------------------------------------------------------

resource "aws_security_group" "rds" {
  name        = "${var.project}-sg-rds"
  description = "Security Group do RDS - acesso PostgreSQL apenas da EC2"
  vpc_id      = var.vpc_id

  ingress {
    description     = "PostgreSQL da EC2"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2.id]
  }

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "${var.project}-sg-rds" })
}
