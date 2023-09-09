//setup provider and region
provider "aws" {
  region = "us-east-1"
  //region = data.aws_region.current.name 
  // hard code the region else it will give cycle error since first provider is run first then data_source
  //will fetch the region to overcome we can harcode or setup a deafult region 
  //with condition
  #   provider "aws" {
  #   region = var.aws_default_region  # Set a default region in your variables
  # }

  # data "aws_region" "current" {}

  # # Conditionally override the region if the data source provides a value
  # provider "aws" {
  #   region = data.aws_region.current.name != "" ? data.aws_region.current.name : var.aws_default_region
  # }
}
//setup vpc 
resource "aws_vpc" "vpc" {
  cidr_block           = var.cidr
  enable_dns_hostnames = var.enable_dns_hostnames

  tags = {
    Name        = "${var.cluster_name}-vpc"
    Environment = var.env
  }
}
//setup public subnet 
//count will define the number subnet to be created
resource "aws_subnet" "public-subnet" {
  count = 2

  availability_zone       = data.aws_availability_zones.available.names[count.index]
  cidr_block              = "10.101.${count.index}.0/24"
  vpc_id                  = aws_vpc.vpc.id
  map_public_ip_on_launch = true


  tags = {
    Name                                        = "${var.cluster_name}-public-subnet"
    Environment                                 = var.env
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    //"kubernetes.io/role/elb"                    = "1"
  }
}
//setup private subnet
resource "aws_subnet" "private-subnet" {
  count = 2

  availability_zone = data.aws_availability_zones.available.names[count.index]
  cidr_block        = "10.101.${count.index + 2}.0/24"
  vpc_id            = aws_vpc.vpc.id

  tags = {
    Name                                        = "${var.cluster_name}-private-subnet"
    Environment                                 = var.env
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    //"kubernetes.io/role/internal-elb"           = "1"
  }
}
//internet gateway
resource "aws_internet_gateway" "ig" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name        = "${var.cluster_name}-igw"
    Environment = var.env
  }
}
//elastic ip for pvt subnet
resource "aws_eip" "eip" {
  tags = {
    Name        = "${var.cluster_name}-eip"
    Environment = var.env
  }
}
//nat gateway
resource "aws_nat_gateway" "ng" {

  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public-subnet.*.id[1]

  tags = {
    Name        = "${var.cluster_name}-ngw"
    Environment = var.env
  }
}
//route table will have route and internet gateway details
resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"                //all traffic
    gateway_id = aws_internet_gateway.ig.id //internet gateway 
  }
  tags = {
    Name        = "${var.cluster_name}-public-rt"
    Environment = var.env
  }
}
//route table will have route and nat gateway details
resource "aws_route_table" "private-rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"           //all traffic 
    gateway_id = aws_nat_gateway.ng.id // nat gateway
  }

  lifecycle {
    ignore_changes = [route]
  }

  tags = {
    Name        = "${var.cluster_name}-private-rt"
    Environment = var.env
  }
}
//route association needed 
resource "aws_route_table_association" "public-rta" {
  count = 2

  subnet_id      = aws_subnet.public-subnet.*.id[count.index]
  route_table_id = aws_route_table.public-rt.id
}
//route association needed 
resource "aws_route_table_association" "private-rta" {
  count = 2

  subnet_id      = aws_subnet.private-subnet.*.id[count.index]
  route_table_id = aws_route_table.private-rt.id
}
