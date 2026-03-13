resource "aws_security_group" "this" {
  name        = "${var.project_name}-${var.environment}-bastion-sg"
  description = "Security group for bastion host"
  vpc_id = var.vpc_id

  ingress {
    description = "Allow SSH from admin's IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.admin_ip]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-bastion-sg"
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_instance" "this" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name
  subnet_id     = var.public_subnet_id
  vpc_security_group_ids = [aws_security_group.this.id]

  tags = {
    Name        = "${var.project_name}-${var.environment}-bastion"
    Environment = var.environment
    Project     = var.project_name
  }
}