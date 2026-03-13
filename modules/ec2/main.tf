resource "aws_security_group" "private_sg" {
  name        = "${var.project_name}-${var.environment}-private-sg"
  description = "Security group for private VMs"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow SSH from bastion host"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = [var.bastion_security_group_id]
  }

  ingress {
    description = "Allow HTTP from admin IP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.admin_cidr]
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

  user_data = var.environment == "nonprod" ? <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl enable httpd
              systemctl start httpd

              PRIVATE_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)

              cat <<HTML > /var/www/html/index.html
              <html>
                <head><title>${var.environment} VM</title></head>
                <body>
                  <h1>${var.owner_name}</h1>
                  <p>Environment: ${var.environment}</p>
                  <p>Private IP: $PRIVATE_IP</p>
                  <p>VM: ${count.index + 1}</p>
                </body>
              </html>
              HTML
              EOF
    : null

  tags = {
    Name        = "${var.project_name}-${var.environment}-vm${count.index + 1}"
    Environment = var.environment
    Project     = var.project_name
    Role        = "private-vm"
  }
}
