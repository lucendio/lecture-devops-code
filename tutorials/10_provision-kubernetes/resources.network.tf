resource "aws_vpc" "vpc" {
  cidr_block = var.cidr
}

resource "aws_subnet" "public" {
  vpc_id = aws_vpc.vpc.id

  cidr_block = var.cidr
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
}
