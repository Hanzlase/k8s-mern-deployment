// Variable: VPC where the temporary build instance will run.
// Provide your existing VPC ID so the instance can be launched inside it.
variable "vpc_id" {
  type        = string
  description = "VPC ID to launch the build instance into"
}

// Variable: Subnet (public) for the build instance.
// Use a public subnet so the instance can download packages and attach a public IP.
variable "subnet_id" {
  type        = string
  description = "Subnet ID (public) to launch the build instance into"
}

// Source: Amazon EBS builder using the latest Ubuntu 22.04 (Jammy).
// Configured to launch a small `t3.micro` instance in `us-east-1` inside your VPC/subnet.
source "amazon-ebs" "ubuntu" {
  region                       = "us-east-1"
  instance_type                = "t3.micro"
  ssh_username                 = "ubuntu"
  ami_name                     = "nginx-custom-{{timestamp}}" // final AMI name
  ami_tags = {
    Name = "nginx-custom-ami" // tag used to find AMI from Terraform
  }

  // Find the official Canonical Ubuntu 22.04 image automatically.
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    owners      = ["099720109477"] # Canonical
    most_recent = true
  }

  // Network placement: use provided VPC/subnet so build runs in your account network.
  vpc_id                       = var.vpc_id
  subnet_id                    = var.subnet_id
  associate_public_ip_address  = true

  // Root volume sizing for the build instance.
  launch_block_device_mappings = [
    {
      device_name           = "/dev/sda1"
      volume_size           = 8
      volume_type           = "gp3"
      delete_on_termination = true
    }
  ]

  tags = {
    created_by = "packer"
  }
}

// Build block: runs the provisioning steps on the temporary instance and produces the AMI.
build "" {
  sources = ["source.amazon-ebs.ubuntu"]

  // Shell provisioner: install nginx and curl, enable service, and replace index.html.
  provisioner "shell" {
    inline = [
      "sudo apt-get update -y",
      "sudo apt-get install -y nginx curl",
      "sudo systemctl enable nginx",
      "sudo systemctl start nginx",
      "echo '<!doctype html><html><head><meta charset=\"utf-8\"><title>Welcome</title></head><body><h1>Welcome to Nginx</h1><p>22F-3686<br/>22F-3654</p></body></html>' | sudo tee /var/www/html/index.html > /dev/null"
    ]
  }
}
