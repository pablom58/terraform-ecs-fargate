# ----- vpc/main.tf ----- #

# ----- Availability Zones ----- #

data "aws_availability_zones" "available" {}

resource "random_shuffle" "az_list" {
  input        = data.aws_availability_zones.available.names
  result_count = var.max_subnets
}

# ----- VPC ----- #

resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    "Name"    = "${var.name_prefix}-vpc"
    "billing" = var.billing_tag
  }
}

# ----- Internet Gateway ----- #

resource "aws_internet_gateway" "ig" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    "Name"    = "${var.name_prefix}-ig"
    "billing" = var.billing_tag
  }
}

# ----- Subnets ----- #

resource "aws_subnet" "private_subnet" {
  count             = var.private_subnet_count
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = element(var.private_cidrs, count.index)
  availability_zone = element(random_shuffle.az_list.result, count.index)

  tags = {
    "Name"    = "${var.name_prefix}-private-subnet-${count.index + 1}"
    "billing" = var.billing_tag
  }
}

resource "aws_subnet" "public_subnet" {
  count                   = var.public_subnet_count
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = element(var.public_cidrs, count.index)
  availability_zone       = element(random_shuffle.az_list.result, count.index)
  map_public_ip_on_launch = true

  tags = {
    "Name"    = "${var.name_prefix}-public-subnet-${count.index + 1}"
    "billing" = var.billing_tag
  }
}

# ----- Public Route Table ----- #

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    "Name" = "${var.name_prefix}-public-route-table"
  }
}

resource "aws_route" "public_route" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.ig.id
}

resource "aws_route_table_association" "public_route_assoc" {
  count          = var.public_subnet_count
  subnet_id      = element(aws_subnet.public_subnet.*.id, count.index)
  route_table_id = aws_route_table.public_rt.id
}

# ----- NAT Gateway ----- #

resource "aws_eip" "nat" {
  count = var.private_subnet_count
  vpc   = true

  tags = {
    "Name" = "${var.name_prefix}-eip-${count.index + 1}"
  }
}

resource "aws_nat_gateway" "nat" {
  count         = var.private_subnet_count
  allocation_id = element(aws_eip.nat.*.id, count.index)
  subnet_id     = element(aws_subnet.public_subnet.*.id, count.index)
  depends_on    = [aws_internet_gateway.ig]

  tags = {
    "Name" = "${var.name_prefix}-nat-${count.index + 1}"
  }
}

# ----- Private Route Table ----- #

resource "aws_route_table" "private_rt" {
  count  = var.private_subnet_count
  vpc_id = aws_vpc.vpc.id

  tags = {
    "Name" = "${var.name_prefix}-private-route-table"
  }
}

resource "aws_route" "private_route" {
  count                  = var.private_subnet_count
  route_table_id         = element(aws_route_table.private_rt.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = element(aws_nat_gateway.nat.*.id, count.index)
}

resource "aws_route_table_association" "private_rt_assoc" {
  count          = var.private_subnet_count
  subnet_id      = element(aws_subnet.private_subnet.*.id, count.index)
  route_table_id = element(aws_route_table.private_rt.*.id, count.index)
}