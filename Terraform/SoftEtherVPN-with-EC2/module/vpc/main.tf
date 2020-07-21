# Vpc
resource "aws_vpc" "this" {
  cidr_block       = "10.0.0.0/16"
  enable_dns_support     = true
  enable_dns_hostnames   = true

  tags = {
    Name = "vpc_for_softethervpn"
  }
}

# Subnet
resource "aws_subnet" "this" {
  vpc_id     = aws_vpc.this.id
  cidr_block = "10.0.32.0/20"
  map_public_ip_on_launch = true #Global IP is automatically assigned.

  tags = {
    Name = "subnet_for_softethervpn"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "igw_for_softethervpn"
  }
}

# Route table
resource "aws_default_route_table" "this" {
  default_route_table_id = aws_vpc.this.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = {
    Name = "route_table_softethervpn"
  }
}

# route table associate
resource "aws_route_table_association" "this" {
  subnet_id      = aws_subnet.this.id
  route_table_id = aws_default_route_table.this.id
}


# security groups
resource "aws_security_group" "this" {
  name        = "sg_softethervpn"
  description = "Allow SoftEtherVPN inbound traffic"
  vpc_id      = aws_vpc.this.id

  ingress {
    description = "for vpn"
    from_port   = 4500
    to_port     = 4500
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "for vpn"
    from_port   = 500
    to_port     = 500
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_tls"
  }
}
