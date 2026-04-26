variable "vpc_id" {
  description = "VPC ID from Assignment 3"
  type        = string
}

variable "public_subnet_id" {
  description = "Public Subnet ID for the Controller"
  type        = string
}

variable "private_subnet_id" {
  description = "Private Subnet ID for the Agent"
  type        = string
}

variable "key_name" {
  description = "Your AWS SSH Key Pair Name"
  type        = string
}

# ------------------------------------------------------
# Security Groups
# ------------------------------------------------------
resource "aws_security_group" "jenkins_controller_sg" {
  name        = "jenkins-controller-sg"
  description = "Security group for Jenkins Controller"
  vpc_id      = var.vpc_id # References your Assignment 3 VPC

  ingress {
    description = "Jenkins UI"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }

  ingress {
    description = "SSH"
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
}

resource "aws_security_group" "jenkins_agent_sg" {
  name        = "jenkins-agent-sg"
  description = "Security group for Jenkins Agent"
  vpc_id      = var.vpc_id

  ingress {
    description     = "SSH from Controller only"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.jenkins_controller_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ------------------------------------------------------
# EC2 Instances
# ------------------------------------------------------
resource "aws_instance" "jenkins_controller" {
  ami                    = "ami-0c7217cdde317cfec" # Standard Ubuntu 22.04 LTS
  instance_type          = "t3.small"
  subnet_id              = var.public_subnet_id
  vpc_security_group_ids = [aws_security_group.jenkins_controller_sg.id]
  key_name               = var.key_name

  # Triggers the bash script you just wrote
  user_data = file("${path.module}/controller-setup.sh")

  tags = {
    Name = "Jenkins-Controller"
  }
}

resource "aws_instance" "jenkins_agent" {
  ami                    = "ami-0c7217cdde317cfec" 
  instance_type          = "t3.small"
  subnet_id              = var.private_subnet_id # Required to be in private subnet
  vpc_security_group_ids = [aws_security_group.jenkins_agent_sg.id]
  key_name               = var.key_name

  # Triggers the bash script you just wrote
  user_data = file("${path.module}/agent-setup.sh")

  tags = {
    Name = "Jenkins-Agent"
  }
}

# Output the Controller IP so you can easily log in
output "jenkins_url" {
  value       = "http://${aws_instance.jenkins_controller.public_ip}"
  description = "The URL to access the Jenkins UI"
}