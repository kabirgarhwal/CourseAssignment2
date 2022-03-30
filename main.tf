#Create the VPC
 resource "aws_vpc" "Main" {                # Creating VPC here
   cidr_block       = "10.0.0.0/16"         # Defining the CIDR block use 10.0.0.0/24 for demo
   instance_tenancy = "default"
    tags = {
    Name = "MainVPC"
  }
 }


#Create Internet Gateway and attach it to VPC
 resource "aws_internet_gateway" "IGW" {    # Creating Internet Gateway
    vpc_id =  aws_vpc.Main.id               # vpc_id will be generated after we create VPC
	
  tags = {
    Name = "IGW"
  }
 }


#Create a Public Subnets.
 resource "aws_subnet" "publicsubnets1" {    # Creating Public Subnets
   vpc_id =  aws_vpc.Main.id
   cidr_block = "10.0.0.0/24"        		# CIDR block of public subnets
   availability_zone = "us-east-1a"
    tags = {
    Name = "PublicSubnet1"
  }
 }

  resource "aws_subnet" "publicsubnets2" {    # Creating Public Subnets
   vpc_id =  aws_vpc.Main.id
   cidr_block = "10.0.1.0/24"        		# CIDR block of public subnets
   availability_zone = "us-east-1a"
    tags = {
    Name = "PublicSubnet2"
  }
 }
 
#Create a Private Subnet
 resource "aws_subnet" "privatesubnets1" {
   vpc_id =  aws_vpc.Main.id
   cidr_block = "10.0.2.0/24"          # CIDR block of private subnets
   availability_zone = "us-east-1b"
   tags = {
    Name = "PrivateSubnet1"
  }
 }

 resource "aws_subnet" "privatesubnets2" {
   vpc_id =  aws_vpc.Main.id
   cidr_block = "10.0.3.0/24"          # CIDR block of private subnets
   availability_zone = "us-east-1b"
   tags = {
    Name = "PrivateSubnet2"
  }
 } 

 
#Route table for Public Subnet's
 resource "aws_route_table" "PublicRT" {    # Creating RT for Public Subnet
    vpc_id =  aws_vpc.Main.id
         route {
    cidr_block = "0.0.0.0/0"               # Traffic from Public Subnet reaches Internet via Internet Gateway
    gateway_id = aws_internet_gateway.IGW.id
     }
	 
	tags = {
    Name = "PublicRoute"
  }
 }



#Route table for Private Subnet's
 resource "aws_route_table" "PrivateRT" {    # Creating RT for Private Subnet
   vpc_id = aws_vpc.Main.id
   route {
   cidr_block = "0.0.0.0/0"             	 # Traffic from Private Subnet reaches Internet via NAT Gateway
   nat_gateway_id = aws_nat_gateway.NATgw.id
   }
   
   tags = {
   Name = "PrivateRoute"
  }
 }


#Route table Association with Public Subnet's
 resource "aws_route_table_association" "PublicRTassociation" {
    subnet_id = aws_subnet.publicsubnets1.id
    route_table_id = aws_route_table.PublicRT.id
 }

	
#Route table Association with Private Subnet's
 resource "aws_route_table_association" "PrivateRTassociation" {
    subnet_id = aws_subnet.privatesubnets1.id
    route_table_id = aws_route_table.PrivateRT.id
 }
 resource "aws_eip" "nateIP" {
   vpc   = true
 }


#Creating the NAT Gateway using subnet_id and allocation_id
 resource "aws_nat_gateway" "NATgw" {
   allocation_id = aws_eip.nateIP.id
   subnet_id = aws_subnet.publicsubnets1.id
   
   tags = {
   Name = "NATgw"
  }
 }
