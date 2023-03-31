terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~>4.0"
    }
  }
}

# Configure the AWS provider 
provider "aws" {
  region = "ap-southeast-1"
}

# Create a VPC
resource "aws_vpc" "my-vpc"{
  cidr_block = var.cidr_block[0]
  tags = {
      Name = "my-vpc"
  }
}

# Create Subnet (Public)
resource "aws_subnet" "my-subnet" {
  vpc_id = aws_vpc.my-vpc.id
  cidr_block = var.cidr_block[1]
  tags = {
      Name = "my-subnet"
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "my-igw" {
  vpc_id = aws_vpc.my-vpc.id
  tags = {
      Name = "my-igw"
  }
}

# Create Security Group
resource "aws_security_group" "my-sg" {
  name = "my-sg"
  description = "Allow ports 22, 80, 443, 8080, 8081"
  vpc_id = aws_vpc.my-vpc.id
  dynamic ingress {
      iterator = port
      for_each = var.ports
          content {
            from_port = port.value
            to_port = port.value
            protocol = "tcp"
            cidr_blocks = ["0.0.0.0/0"]
          }
  }
  egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
      Name = "my-sg"
  }
}

# Create route table and association
resource "aws_route_table" "my-rtb" {
  vpc_id = aws_vpc.my-vpc.id
  route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.my-igw.id
  }
  tags = {
      Name = "my-rtb"
  }
}

resource "aws_route_table_association" "my-rtb-a" {
  subnet_id = aws_subnet.my-subnet.id
  route_table_id = aws_route_table.my-rtb.id
}

# Create an Amazon Linux 2 instance to Jenkins
resource "aws_instance" "Jenkins" {
  ami           = var.ami
  instance_type = var.instance_type
  key_name = "mhviet-key"
  vpc_security_group_ids = [aws_security_group.my-sg.id]
  subnet_id = aws_subnet.my-subnet.id
  associate_public_ip_address = true
  user_data = file("./userdata/install-jenkins.sh")

  tags = {
    Name = "Jenkins"
  }
}

# Create an Amazon Linux 2 instance to Ansible
resource "aws_instance" "Ansible" {
  ami           = var.ami
  instance_type = var.instance_type
  key_name = "mhviet-key"
  vpc_security_group_ids = [aws_security_group.my-sg.id]
  subnet_id = aws_subnet.my-subnet.id
  associate_public_ip_address = true
  user_data = file("./userdata/install-ansible.sh")

  tags = {
    Name = "Ansible"
  }
}

# Create an Amazon Linux 2 instance Sonatype Nexus
resource "aws_instance" "Nexus" {
  ami           = var.ami
  instance_type = var.instance_type_for_nexus
  key_name = "mhviet-key"
  vpc_security_group_ids = [aws_security_group.my-sg.id]
  subnet_id = aws_subnet.my-subnet.id
  associate_public_ip_address = true
  user_data = file("./userdata/install-nexus.sh")

  tags = {
    Name = "Nexus"
  }
}

# Create an Amazon Linux 2 instance to Docker
resource "aws_instance" "Docker" {
  ami           = var.ami
  instance_type = var.instance_type
  key_name = "mhviet-key"
  vpc_security_group_ids = [aws_security_group.my-sg.id]
  subnet_id = aws_subnet.my-subnet.id
  associate_public_ip_address = true
  user_data = file("./userdata/install-docker.sh")

  tags = {
    Name = "Docker"
  }
}