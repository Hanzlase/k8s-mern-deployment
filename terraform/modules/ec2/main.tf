// EC2 module: creates a small public web instance and a private instance,
// plus SSH key material and security groups. Outputs provide easy access info.

// 1) Find a recent Amazon Linux 2023 AMI to use for instances.
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

// 2) Generate an SSH keypair locally so Terraform can provision and you can SSH in.
resource "tls_private_key" "rsa_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "tf_key" {
  key_name   = "assignment3-key"
  public_key = tls_private_key.rsa_key.public_key_openssh
}

// Save the private key to the module folder (read-only) for operator access.
resource "local_sensitive_file" "private_key" {
  content         = tls_private_key.rsa_key.private_key_pem
  filename        = "${path.module}/assignment3-key.pem"
  file_permission = "0400" // SSH requires private key file to be read-only
}

// 3) Security group for the public web server: allows HTTP and SSH from anywhere.
resource "aws_security_group" "public_web_sg" {
  name        = "public-web-sg"
  description = "Allow HTTP and SSH inbound traffic"
  vpc_id      = aws_vpc.main.id // pulled from the VPC module

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

// 4) Security group for the private instance: restricts SSH access to only the public web SG.
resource "aws_security_group" "private_db_sg" {
  name        = "private-db-sg"
  description = "Allow SSH only from the Bastion Host"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "SSH from Public Web SG"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.public_web_sg.id] // tight access
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

// 5) Public EC2 instance: acts as a bastion and simple web server (boots with nginx).
resource "aws_instance" "public_web" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.public_1.id
  vpc_security_group_ids      = [aws_security_group.public_web_sg.id]
  key_name                    = aws_key_pair.tf_key.key_name
  associate_public_ip_address = true

  // Bootstrap installs nginx so HTTP works immediately.
  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y nginx
              systemctl start nginx
              systemctl enable nginx
              EOF
  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y PHP:8.1
              systemctl start PHP:8.1
              systemctl enable PHP:8.1
              EOF

  tags = {
    Name = "public-web-server"
  }
}

// 6) Private EC2 instance: separate subnet and security group for isolation.
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

// 7) Outputs: useful connection information for operators or scripts.
output "public_web_ip" {
  description = "Public IP of the web server"
  value       = aws_instance.public_web.public_ip
}

output "private_db_ip" {
  description = "Private IP of the database server"
  value       = aws_instance.private_db.private_ip
}