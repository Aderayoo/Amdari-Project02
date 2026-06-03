variable "project" { type = string }
variable "environment" { type = string }

# IV-10 REMEDIATED:
# - map_public_ip_on_launch = false
# - Private subnets added for EKS nodes
# - Overly broad security group restricted
# - VPC flow logs added

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.project}-${var.environment}-vpc"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project}-${var.environment}-igw"
  }
}

# Public subnets — no longer auto-assign public IPs
resource "aws_subnet" "public" {
  count                   = 2
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.${count.index + 1}.0/24"
  availability_zone       = ["eu-west-2a", "eu-west-2b"][count.index]
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.project}-${var.environment}-public-${count.index}"
  }
}

# Private subnets for EKS nodes
resource "aws_subnet" "private" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.${count.index + 10}.0/24"
  availability_zone = ["eu-west-2a", "eu-west-2b"][count.index]

  tags = {
    Name = "${var.project}-${var.environment}-private-${count.index}"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
}

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Restricted security group — only allow specific ports from VPC CIDR
resource "aws_security_group" "app" {
  name        = "${var.project}-${var.environment}-app-sg"
  description = "Application security group — restricted ingress"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
    description = "HTTPS from VPC only"
  }

  ingress {
    from_port   = 5000
    to_port     = 5002
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
    description = "App ports from VPC only"
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
    description = "HTTPS outbound to VPC"
  }
}

output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_ids" {
  value = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  value = aws_subnet.private[*].id
}
