# main.tf

# VPC module: creates a simple VPC with public and private subnets,
# an Internet Gateway, a NAT gateway for outbound access from private subnets,
# and route tables. Exposes subnet and VPC IDs as outputs for other modules.

# 1) Provider configuration (region for resources created by this module).
provider "aws" {
  region = "us-east-1" # Change if you need a different AWS region
}

# 2) Lookup available AZs so we can place subnets in different zones.
data "aws_availability_zones" "available" {
  state = "available"
}

# 3) Create the VPC. This is the network boundary for all subnets/resources.
resource "aws_vpc" "main" {
  cidr_block           = "192.168.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "assignment-3-vpc"
  }
}

# 4) Public subnets: used for load balancers, NAT gateway, or public-facing instances.
# We create two across separate AZs for availability.
resource "aws_subnet" "public_1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-1"
  }
}

resource "aws_subnet" "public_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-2"
  }
}

resource "aws_subnet" "public_3" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "192.168.168.3.0/24"
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-3"
  }
}

# 5) Private subnets: for application instances that should not be directly reachable
# from the internet. They will route outbound traffic through the NAT gateway.
resource "aws_subnet" "private_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.10.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "private-subnet-1"
  }
}

resource "aws_subnet" "private_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.11.0/24"
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = {
    Name = "private-subnet-2"
  }
}

# 6) Internet Gateway: allows resources in public subnets to reach the internet.
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main-igw"
  }
}

# 7) Allocate an Elastic IP which the NAT gateway will use for outbound traffic.
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "nat-eip"
  }
}

# 8) NAT Gateway: enables instances in private subnets to access the internet
# (for package updates, etc.) while remaining unreachable from the internet.
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_1.id

  # Ensure IGW exists before creating NAT
  depends_on = [aws_internet_gateway.igw]

  tags = {
    Name = "main-nat-gw"
  }
}

# 9) Public route table: routes internet-bound traffic from public subnets
# to the Internet Gateway.
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-route-table"
  }
}

# Associate the public route table with each public subnet.
resource "aws_route_table_association" "public_1" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_2" {
  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_route_table.public.id
}

# 10) Private route table: sends internet-bound traffic from private subnets
# through the NAT gateway so instances can access updates without being public.
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "private-route-table"
  }
}

# Associate the private route table with each private subnet.
resource "aws_route_table_association" "private_1" {
  subnet_id      = aws_subnet.private_1.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_2" {
  subnet_id      = aws_subnet.private_2.id
  route_table_id = aws_route_table.private.id
}

#+ Outputs: expose useful IDs for other modules or the root module to consume
output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_ids" {
  value = [aws_subnet.public_1.id, aws_subnet.public_2.id]
}

output "private_subnet_ids" {
  value = [aws_subnet.private_1.id, aws_subnet.private_2.id]
}

output "nat_gateway_id" {
  value = aws_nat_gateway.nat.id
}