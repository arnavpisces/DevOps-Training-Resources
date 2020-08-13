provider "aws" {
  profile = "default"
  region  = var.region
}

resource "aws_vpc" "vpc" {
  cidr_block           = var.cidr_vpc
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    "Environment" = var.environment_tag
    Name          = "terraform-vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    "Environment" = var.environment_tag
  }
}

resource "aws_subnet" "subnet_public_1" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.cidr_subnet_1
  map_public_ip_on_launch = false #default is false
  availability_zone       = var.availability_zone["zone-a"]
}

resource "aws_subnet" "subnet_public_2" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.cidr_subnet_2
  availability_zone = var.availability_zone["zone-b"]
}

resource "aws_route_table" "rtb_public" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "rta_subnet_public_1" {
  subnet_id      = aws_subnet.subnet_public_1.id
  route_table_id = aws_route_table.rtb_public.id
}

resource "aws_route_table_association" "rta_subnet_public_2" {
  subnet_id      = aws_subnet.subnet_public_2.id
  route_table_id = aws_route_table.rtb_public.id
}

resource "aws_subnet" "subnet_private_1" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.cidr_subnet_1_pvt
  availability_zone = var.availability_zone["zone-a"]
}
resource "aws_subnet" "subnet_private_2" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.cidr_subnet_2_pvt
  availability_zone = var.availability_zone["zone-b"]
}
resource "aws_route_table" "rtb_private" {
  vpc_id = aws_vpc.vpc.id
}
resource "aws_route_table_association" "rta_subnet_private_1" {
  subnet_id      = aws_subnet.subnet_private_1.id
  route_table_id = aws_route_table.rtb_private.id
}
resource "aws_route_table_association" "rta_subnet_private_2" {
  subnet_id      = aws_subnet.subnet_private_2.id
  route_table_id = aws_route_table.rtb_private.id
}

resource "aws_security_group" "sg_test" {
  name   = "sg_test"
  vpc_id = aws_vpc.vpc.id

  ingress {
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
  ingress{
    from_port = 80
    to_port=80
    protocol="tcp"
    cidr_blocks=["0.0.0.0/0"]
  }
  tags = {
    "Environment" = var.environment_tag
  }
}

resource "aws_network_acl" "acl_public_1" {
  vpc_id     = aws_vpc.vpc.id
  subnet_ids = [aws_subnet.subnet_public_1.id]
  egress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }
  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }
}
resource "aws_network_acl" "acl_public_2" {
  vpc_id     = aws_vpc.vpc.id
  subnet_ids = [aws_subnet.subnet_public_2.id]
  egress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }
  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }
}
resource "aws_network_acl" "acl_private_1" {
  vpc_id     = aws_vpc.vpc.id
  subnet_ids = [aws_subnet.subnet_private_1.id]
  egress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "deny"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }
  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "deny"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }
}
resource "aws_network_acl" "acl_private_2" {
  vpc_id     = aws_vpc.vpc.id
  subnet_ids = [aws_subnet.subnet_private_2.id]
  egress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "deny"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }
  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "deny"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }
}
resource "aws_key_pair" "ansible_test_keypair"{
  key_name = var.test_key_pair["key_name"]
  public_key=file("../vpc-implementation/terraform.pub")
}
resource "aws_instance" "ansible_test"{
  ami=var.free_instance["ami"]
  instance_type = var.free_instance["instance_type"]
  key_name=aws_key_pair.ansible_test_keypair.key_name
  vpc_security_group_ids=[aws_security_group.sg_test.id]
  subnet_id=aws_subnet.subnet_public_1.id
  
  connection{
    type="ssh"
    user="ec2-user"
    private_key=file("../vpc-implementation/terraform")
    host=self.public_ip
  }
  provisioner "remote-exec" {
    inline=["sudo apt-get -qq install python -y"]
  }
}