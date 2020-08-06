locals {
  environment      = "ci"
  vpc_cidr         = "10.0.0.0/16"
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "main" {
  cidr_block           = local.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = format("%s",local.environment)
  }
}

resource "aws_subnet" "public" {
  count = 1

  vpc_id            = aws_vpc.main.id
  availability_zone = data.aws_availability_zones.available.names[count.index]
  cidr_block        = cidrsubnet(local.vpc_cidr,8,count.index)

  tags = {
    Name = format("%s-%02d",local.environment,count.index)
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = format("%s",local.environment)
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = format("%s",local.environment)
  }
}

resource "aws_route_table_association" "public" {
  count = length(aws_subnet.public)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "public" {
  name        = format("%s-public",local.environment)
  description = format("%s environment public security group",local.environment)
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Allow SSH from everywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  ingress {
    description = "Allow HTTP from everywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  ingress {
    description = "Allow HTTPS from everywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  tags = {
    Name = format("%s-public",local.environment)
  }
}

data "aws_ami" "default" {
  most_recent = true
  owners      = [ "137112412989" ]

  filter {
    name   = "name"
    values = [ "amzn2-ami-hvm-2.0.????????.?-x86_64-gp2" ]
  }
}

resource "tls_private_key" "main" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "main" {
  key_name   = format("%s",local.environment)
  public_key = tls_private_key.main.public_key_openssh
}

resource "aws_instance" "public" {
  count = 1

  ami               = data.aws_ami.default.id
  instance_type     = "t3.micro"
  availability_zone = data.aws_availability_zones.available.names[count.index]

  associate_public_ip_address = true

  iam_instance_profile = aws_iam_instance_profile.main.id

  key_name = aws_key_pair.main.key_name

  subnet_id = aws_subnet.public[count.index].id
  vpc_security_group_ids = [ aws_security_group.public.id ]

  user_data = file("files/docker/amazon-linux.sh")

  root_block_device {
    delete_on_termination = true
    volume_type = "standard"
    volume_size = 40
  }

  tags = {
    Name          = format("%s-%02d",local.environment,count.index)
    environment   = local.environment
    application   = "jenkins"
    exposition    = "public"
  }

  lifecycle {
    ignore_changes = [ ami ]
  }
}