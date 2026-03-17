# Fetches available availability zones in the current region.
data "aws_availability_zones" "azs" {
  state = "available"
}

# Creates the primary VPC for the application.
resource "aws_vpc" "book-review-vpc" {

  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "${var.project}-vpc"
  }
}


# Public subnet for web tier in the first availability zone.
resource "aws_subnet" "web_subnet_1" {

  vpc_id                  = aws_vpc.book-review-vpc.id
  cidr_block              = var.web_subnet_1_cidr
  availability_zone       = data.aws_availability_zones.azs.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.project}-web-subnet-1"
  }
}


# Public subnet for web tier in the second availability zone.
resource "aws_subnet" "web_subnet_2" {

  vpc_id                  = aws_vpc.book-review-vpc.id
  cidr_block              = var.web_subnet_2_cidr
  availability_zone       = data.aws_availability_zones.azs.names[1]
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.project}-web-subnet-2"
  }
}

# Private subnet for app tier in the first availability zone.
resource "aws_subnet" "app_subnet_1" {
  vpc_id            = aws_vpc.book-review-vpc.id
  availability_zone = data.aws_availability_zones.azs.names[0]
  cidr_block        = var.app_subnet_1_cidr 

  tags = {
    Name        = "${var.project}-app-subnet-1"
  }
}

# Private subnet for app tier in the second availability zone.
resource "aws_subnet" "app_subnet_2" {
  vpc_id            = aws_vpc.book-review-vpc.id
  availability_zone = data.aws_availability_zones.azs.names[1]
  cidr_block        = var.app_subnet_2_cidr 

  tags = {
    Name        = "${var.project}-app-subnet-2"
  }
}


# Private subnet for database tier in the first availability zone.
resource "aws_subnet" "db_subnet_1" {
  vpc_id            = aws_vpc.book-review-vpc.id
  availability_zone = data.aws_availability_zones.azs.names[0]
  cidr_block        = var.db_subnet_1_cidr 

  tags = {
    Name        = "${var.project}-db-subnet-1"
  }
}

# Private subnet for database tier in the second availability zone.
resource "aws_subnet" "db_subnet_2" {
  vpc_id            = aws_vpc.book-review-vpc.id
  availability_zone = data.aws_availability_zones.azs.names[1]
  cidr_block        = var.db_subnet_2_cidr 

  tags = {
    Name        = "${var.project}-db-subnet-2"
  }
}

# Internet gateway for public internet access from the VPC.
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.book-review-vpc.id

  tags = {
    Name = "${var.project}-igw"
  }
}

# Route table for public subnets with internet route.
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.book-review-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

# Associates the first web subnet with the public route table.
resource "aws_route_table_association" "public_rt_assoc_1" {
  subnet_id      = aws_subnet.web_subnet_1.id
  route_table_id = aws_route_table.public_rt.id
}

# Associates the second web subnet with the public route table.
resource "aws_route_table_association" "public_rt_assoc_2" {
  subnet_id      = aws_subnet.web_subnet_2.id
  route_table_id = aws_route_table.public_rt.id
}

# Elastic IP allocated for the NAT gateway.
resource "aws_eip" "nat_eip" {
  domain = "vpc"
  depends_on = [
    aws_internet_gateway.igw
  ]

  tags = {
    Name = "${var.project}-nat-eip"
  }
}

# NAT gateway enabling outbound internet for private subnets.
resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.web_subnet_1.id

  tags = {
    Name = "${var.project}-nat-gw"
  }
}

# Route table for private subnets with NAT-based internet access.
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.book-review-vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw.id
  }
}

# Associates first app subnet with the private route table.
resource "aws_route_table_association" "private_rt_assoc_1" {
  subnet_id      = aws_subnet.app_subnet_1.id
  route_table_id = aws_route_table.private_rt.id
}
# Associates second app subnet with the private route table.
resource "aws_route_table_association" "private_rt_assoc_2" {
  subnet_id      = aws_subnet.app_subnet_2.id
  route_table_id = aws_route_table.private_rt.id
}
# Associates first database subnet with the private route table.
resource "aws_route_table_association" "private_rt_assoc_3" {
  subnet_id      = aws_subnet.db_subnet_1.id
  route_table_id = aws_route_table.private_rt.id
}
# Associates second database subnet with the private route table.
resource "aws_route_table_association" "private_rt_assoc_4" {
  subnet_id      = aws_subnet.db_subnet_2.id
  route_table_id = aws_route_table.private_rt.id
}