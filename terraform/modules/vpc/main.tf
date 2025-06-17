# VPC
resource "aws_vpc" "app_vpc" {
  cidr_block = var.vpc_cidr
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = { 
    Name = "${var.name}-vpc" 
    }
}

# Internet Gateway
resource "aws_internet_gateway" "app_ig" {
  vpc_id = aws_vpc.app_vpc.id
  tags = { 
    Name = "${var.name}-igw" 
    }
}

# Public Subnets
resource "aws_subnet" "public" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.app_vpc.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.name}-public-${count.index + 1}"
  }
}

# Private Subnets
resource "aws_subnet" "private" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.app_vpc.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]
  tags = {
    Name = "${var.name}-private-${count.index + 1}"
  }
}

# Elastic IP for NAT
resource "aws_eip" "app_nat_eip" {
  vpc = true
  depends_on = [aws_internet_gateway.app_ig]
  tags = { 
    Name = "${var.name}-nat-eip" 
    }
}

# NAT Gateway in first public subnet
resource "aws_nat_gateway" "app_nat" {
  allocation_id = aws_eip.app_nat_eip.id
  subnet_id     = aws_subnet.public[0].id
  tags = { 
    Name = "${var.name}-nat-gw" 
    }
}

# Route Table for Public Subnets
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.app_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.app_ig.id
  }
  tags = { 
    Name = "${var.name}-public-rt" 
    }
}

# Associate Public Subnets with Public RT
resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Route Table for Private Subnets
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.app_vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.app_nat.id
  }
  tags = { 
    Name = "${var.name}-private-rt" 
    }
}

# Associate Private Subnets with Private RT
resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}
