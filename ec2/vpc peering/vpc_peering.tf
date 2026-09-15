#Creating the vpc A
resource "aws_vpc" "vpc_A" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "vpc-A"
  }
}
#Creating the vpc B
resource "aws_vpc" "vpc_B" {
  cidr_block = "192.168.0.0/16"
  tags = {
    Name = "vpc-B"
  }
}
#Creating the pub subnet in vpc A
resource "aws_subnet" "subnet_A" {
  vpc_id = aws_vpc.vpc_A.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "subnet-A"
  }
}
#Creating the pub subnet in vpc B
resource "aws_subnet" "subnet_B" {
  vpc_id = aws_vpc.vpc_B.id
  cidr_block = "192.168.1.0/24"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = true
  tags = {
    Name = "subnet-B"
  }
}
#Creating the rt in vpc A
resource "aws_route_table" "rt_A" {
  vpc_id = aws_vpc.vpc_A.id
  route {
    cidr_block = "192.168.0.0/16"
    vpc_peering_connection_id = aws_vpc_peering_connection.peering.id
  }
  tags = {
    Name = "rt-A"
  }
}
#Creating the rt in vpc B
resource "aws_route_table" "rt_B" {
  vpc_id = aws_vpc.vpc_B.id
  route {
    cidr_block = "10.0.0.0/16"
    vpc_peering_connection_id = aws_vpc_peering_connection.peering.id
  }
  tags = {
    Name = "rt-B"
  }
}
#Associating subnet in vpc A
resource "aws_route_table_association" "associate_A" {
  route_table_id = aws_route_table.rt_A.id
  subnet_id = aws_subnet.subnet_A.id
}
#Associating subnet in vpc B
resource "aws_route_table_association" "associate_B" {
  route_table_id = aws_route_table.rt_B.id
  subnet_id = aws_subnet.subnet_B.id
}
#Establishing the vpc peering within same region
resource "aws_vpc_peering_connection" "peering" {
  vpc_id = aws_vpc.vpc_A.id
  peer_vpc_id = aws_vpc.vpc_B.id
  auto_accept = true
}
#Setting the sg for the instance in vpc A
resource "aws_security_group" "sg_A" {
  name = "demo-sg-A"
  vpc_id = aws_vpc.vpc_A.id
  ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["192.168.0.0/16"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
#Setting the sg for the instance in vpc B
resource "aws_security_group" "sg_B" {
  name = "demo-sg-B"
  vpc_id = aws_vpc.vpc_B.id
  ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["10.0.0.0/16"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
#Creating the ec2 instance in vpc A
resource "aws_instance" "instance_A" {
  ami = "demo ami for testing!"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.subnet_A.id
  vpc_security_group_ids = [aws_security_group.sg_A.id]
  tags = {
    Name = "instance-vpc-A"
  }
}
#Creating the ec2 instance in vpc B
resource "aws_instance" "instance_B" {
  ami = "demo ami for testing!"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.subnet_B.id
  vpc_security_group_ids = [aws_security_group.sg_B.id]
  tags = {
    Name = "instance-vpc-B"
  }
}