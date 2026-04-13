# ec2.tf

# 1. Fetch the latest Amazon Linux 2023 Image automatically
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

# 2. Generate an SSH Key Pair securely via Terraform
resource "tls_private_key" "rsa_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "tf_key" {
  key_name   = "assignment3-key"
  public_key = tls_private_key.rsa_key.public_key_openssh
}

# Save the private key to your local machine so you can use it to log in
resource "local_sensitive_file" "private_key" {
  content         = tls_private_key.rsa_key.private_key_pem
  filename        = "${path.module}/assignment3-key.pem"
  file_permission = "0400" # Read-only permission required by SSH
}

# 3. Security Group for Public Web Server (Allows HTTP and SSH from anywhere)
resource "aws_security_group" "public_web_sg" {
  name        = "public-web-sg"
  description = "Allow HTTP and SSH inbound traffic"
  vpc_id      = aws_vpc.main.id # References the VPC from main.tf

  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "public-web-sg"
  }
}

# 4. Security Group for Private Server (Allows SSH ONLY from the Public Web SG)
resource "aws_security_group" "private_db_sg" {
  name        = "private-db-sg"
  description = "Allow SSH only from the Bastion Host"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "SSH from Public Web SG"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.public_web_sg.id] # Strict rule!
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "private-db-sg"
  }
}

# 5. Public EC2 Instance (Bastion & Web Server)
resource "aws_instance" "public_web" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.public_1.id
  vpc_security_group_ids      = [aws_security_group.public_web_sg.id]
  key_name                    = aws_key_pair.tf_key.key_name
  associate_public_ip_address = true

  # Bootstrap script to install and start Nginx automatically
  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y nginx
              systemctl start nginx
              systemctl enable nginx
              EOF

  tags = {
    Name = "public-web-server"
  }
}

# 6. Private EC2 Instance
resource "aws_instance" "private_db" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.private_1.id
  vpc_security_group_ids = [aws_security_group.private_db_sg.id]
  key_name               = aws_key_pair.tf_key.key_name

  tags = {
    Name = "private-db-server"
  }
}

# 7. Outputs to help you connect
output "public_web_ip" {
  description = "Public IP of the web server"
  value       = aws_instance.public_web.public_ip
}

output "private_db_ip" {
  description = "Private IP of the database server"
  value       = aws_instance.private_db.private_ip
}