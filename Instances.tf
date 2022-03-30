#SG for Bastion Host
resource "aws_security_group" "sg_bastion_host" {
  name        = "Bastion host SG"
  vpc_id      = aws_vpc.Main.id

  ingress {
    description = "allow SSH"
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
}

#SG for Jenkins
resource "aws_security_group" "sg_private_instances" {
  name        = "Private Instances SG"
  vpc_id      = aws_vpc.Main.id

  ingress {
    description = "SG for Jenkins Instance"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.Main.cidr_block]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#SG for Web App
resource "aws_security_group" "sg_public_web" {
  name        = "Public Web SG"
  vpc_id      = aws_vpc.Main.id

  ingress {
    description = "Http Traffic"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.Main.cidr_block]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

provider "aws" {
  region = "us-east-1"
}
resource "aws_instance" "BastionHost" {
  ami 						  = "ami-04505e74c0741db8d"
  instance_type				  = "t2.micro"
  key_name					  = "test"
  availability_zone 		  = "us-east-1a"
  associate_public_ip_address = "true"
  tenancy                     ="default"
  subnet_id                   = aws_subnet.publicsubnets1.id
  vpc_security_group_ids      = [aws_security_group.sg_bastion_host.id]
  tags = {
    Name = "BastionHost"
  }
	provisioner "local-exec" {
	command = "echo ${aws_instance.BastionHost.public_ip} >> public_ip.txt"
  }
}

resource "aws_instance" "Jenkins" {
  ami                    = "ami-000722651477bd39b"
  instance_type          = "t2.micro"
  key_name               = "test"
  availability_zone 	 = "us-east-1b"
  vpc_security_group_ids = [aws_security_group.sg_private_instances.id]
  subnet_id              = aws_subnet.privatesubnets1.id
  tags = {
    Name = "Jenkins"
  }
  provisioner "local-exec" {
    command = "echo ${aws_instance.Jenkins.private_ip} >> private_ips.txt"
  }
}

resource "aws_instance" "App" {
  ami                    = "ami-000722651477bd39b"
  instance_type          = "t2.micro"
  key_name               = "test"
  availability_zone 	 = "us-east-1b"
  vpc_security_group_ids = [aws_security_group.sg_public_web.id]
  subnet_id              = aws_subnet.privatesubnets2.id
  tags = {
    Name = "App"
  }
  provisioner "local-exec" {
    command = "echo ${aws_instance.App.private_ip} >> private_ips.txt"
  }
}
