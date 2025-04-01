resource "aws_default_vpc" "default" {
}

resource "aws_security_group" "rds" {
  name        = "${var.aws_environment_name}-rds-sg"
  description = "Postgres traffic"
  vpc_id      = aws_default_vpc.default.id

  tags = {
    Name = var.aws_environment_name
  }

  # Postgres traffic - public RDS for demo purposes. Should be private and only accessible from Lambda otherwise
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}