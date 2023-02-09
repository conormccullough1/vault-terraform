# Create and populate the rules of a security group to allow access to/from the server
resource "aws_security_group" "conor-vault-sg" {

  name = "conor-vault-sg"
  description = "Security Group for Conor Test"
  vpc_id = "${aws_vpc.conor-vault-vpc.id}"

  ingress {
    from_port   = 8200
    to_port     = 8200
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

# Create a VPC for the Vault server to use
resource "aws_vpc" "conor-vault-vpc" {
  cidr_block       = "10.0.0.0/16"
  tags = {
    Name = "Conor Vault VPC"
  }
}

# Make sure the route table we create, "conor-route-table", is associated with our VPC
resource "aws_main_route_table_association" "conor-vpc-route-association" {
  vpc_id = aws_vpc.conor-vault-vpc.id
  route_table_id = aws_route_table.conor-route-table.id
}

# Created this because vpc_id is not supported for aws_instance resource type
resource "aws_subnet" "conor-subnet" {
  vpc_id            = aws_vpc.conor-vault-vpc.id
  cidr_block        = "10.0.0.0/24"
  availability_zone = "ap-northeast-2b"

  tags = {
    Name = "conor-tf-subnet"
  }
}

# Add an Internet Gateway to the VPC so it's able to reach the internet, provide our new internet gateway ID for each of the public route's gateways
resource "aws_internet_gateway" "conor-gw" {
  vpc_id = aws_vpc.conor-vault-vpc.id
}

# Create the route table, attach it to the VPC we created
resource "aws_route_table" "conor-route-table" {
  vpc_id = aws_vpc.conor-vault-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.conor-gw.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id = aws_internet_gateway.conor-gw.id
  }

  tags = {
    Name = "Route table for TF tests"
  }
}
