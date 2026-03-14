resource "aws_security_group" "private_sg" {
  name        = "${var.project_name}-${var.environment}-private-sg"
  description = "Security group for private VMs"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow SSH from bastion host"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.bastion_private_ip}/32"]
  }

  dynamic "ingress" {
    for_each = var.environment == "nonprod" ? [1] : []

    content {
      description     = "Allow HTTP from bastion host"
      from_port       = 80
      to_port         = 80
      protocol        = "tcp"
      cidr_blocks = ["${var.bastion_private_ip}/32"]
    }
  }

  dynamic "ingress" {
    for_each = var.environment == "prod" ? [1] : []

    content {
      description = "Allow MySQL from bastion host"
      from_port   = 3306
      to_port     = 3306
      protocol    = "tcp"
      cidr_blocks = ["${var.bastion_private_ip}/32"]
    }
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-private-sg"
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_instance" "private_vm" {
  count = 2

  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = var.private_subnet_ids[count.index]
  vpc_security_group_ids = [aws_security_group.private_sg.id]

  user_data = length(var.user_data_list) > count.index ? var.user_data_list[count.index] : null

  tags = {
    Name        = "${var.project_name}-${var.environment}-vm${count.index + 1}"
    Environment = var.environment
    Project     = var.project_name
    Role        = "private-vm"
  }
}
