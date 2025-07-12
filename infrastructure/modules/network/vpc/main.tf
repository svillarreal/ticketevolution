data "aws_availability_zones" "available_azs" {
  state = "available"
}

resource "aws_vpc" "main" {
  cidr_block           = "10.2.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
}

locals {
  azs           = slice(data.aws_availability_zones.available_azs.names, 0, 2)
  public_cidrs  = ["10.2.1.0/24", "10.2.2.0/24"]
  private_cidrs = ["10.2.3.0/24", "10.2.4.0/24"]
}

resource "aws_subnet" "private" {
  for_each          = zipmap(local.azs, local.private_cidrs)
  vpc_id            = aws_vpc.main.id
  availability_zone = each.key
  cidr_block        = each.value
  tags              = var.private_subnet_tags
}

resource "aws_subnet" "public" {
  for_each                = zipmap(local.azs, local.public_cidrs)
  vpc_id                  = aws_vpc.main.id
  availability_zone       = each.key
  cidr_block              = each.value
  map_public_ip_on_launch = true
  tags                    = var.public_subnet_tags
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
}

resource "aws_eip" "ngw_eip" {
  depends_on = [aws_internet_gateway.igw]
}
resource "aws_nat_gateway" "ngw" {
  subnet_id     = values(aws_subnet.public)[0].id
  allocation_id = aws_eip.ngw_eip.id
  depends_on    = [aws_internet_gateway.igw]

}
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "public_subnet_aws_route_table_association" {
  for_each       = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.ngw.id
  }
}

resource "aws_route_table_association" "private_subnet_aws_route_table_association" {
  for_each       = aws_subnet.private
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private_route_table.id
}
