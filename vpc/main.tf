##############################################
# VPC
##############################################
resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support

  tags = merge(local.common_tags, {
    Name = local.vpc_name
  })
}

##############################################
# Internet Gateway
##############################################
resource "aws_internet_gateway" "this" {
  count  = var.create_igw ? 1 : 0
  vpc_id = aws_vpc.this.id

  tags = merge(local.common_tags, {
    Name = "igw-${var.environment}"
  })
}

##############################################
# Public Subnets
##############################################
resource "aws_subnet" "public" {
  # checkov:skip=CKV_AWS_130: Public subnet requires public IPs
  count = length(var.public_subnet_cidrs)

  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.azs[count.index % length(var.azs)]
  map_public_ip_on_launch = true

  tags = merge(local.common_tags, {
    Name = "snet-pub-${var.environment}-${var.azs[count.index % length(var.azs)]}-${count.index + 1}"
    Tier = "public"
  })
}

##############################################
# Private Subnets
##############################################
resource "aws_subnet" "private" {
  count = length(var.private_subnet_cidrs)

  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.azs[count.index % length(var.azs)]

  tags = merge(local.common_tags, {
    Name = "snet-pri-${var.environment}-${var.azs[count.index % length(var.azs)]}-${count.index + 1}"
    Tier = "private"
  })
}

##############################################
# Private Subnets
##############################################
resource "aws_subnet" "private" {
  count = length(var.private_subnet_cidrs)

  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.azs[count.index % length(var.azs)]

  tags = merge(local.common_tags, {
    Name    = "snet-pri-${var.environment}-${var.azs[count.index % length(var.azs)]}-${count.index + 1}"
    Tier    = "private"
    Purpose = length(var.private_subnet_purpose) > 0 ? var.private_subnet_purpose[count.index] : ""
  })
}

##############################################
# Elastic IPs for NAT Gateways
##############################################
resource "aws_eip" "nat" {
  count  = local.nat_gateway_count
  domain = "vpc"

  tags = merge(local.common_tags, {
    Name = "eip-${var.environment}-nat-${count.index + 1}"
  })

  depends_on = [aws_internet_gateway.this]
}

##############################################
# NAT Gateways
##############################################
resource "aws_nat_gateway" "this" {
  count = local.nat_gateway_count

  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index % length(aws_subnet.public)].id

  tags = merge(local.common_tags, {
    Name = "nat-${var.environment}-${var.azs[count.index % length(var.azs)]}"
  })

  depends_on = [aws_internet_gateway.this]
}

##############################################
# Public Route Table
##############################################
resource "aws_route_table" "public" {
  count  = length(var.public_subnet_cidrs) > 0 ? 1 : 0
  vpc_id = aws_vpc.this.id

  tags = merge(local.common_tags, {
    Name = "rt-pub-${var.environment}"
  })
}

resource "aws_route" "public_internet" {
  count = var.create_igw && length(var.public_subnet_cidrs) > 0 ? 1 : 0

  route_table_id         = aws_route_table.public[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this[0].id
}

resource "aws_route_table_association" "public" {
  count = length(var.public_subnet_cidrs)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public[0].id
}

##############################################
# Private Route Tables
##############################################
resource "aws_route_table" "private" {
  count  = length(var.private_subnet_cidrs) > 0 ? (var.single_nat_gateway ? 1 : length(var.private_subnet_cidrs)) : 0
  vpc_id = aws_vpc.this.id

  tags = merge(local.common_tags, {
    Name = "rt-pri-${var.environment}"
  })
}

resource "aws_route" "private_nat" {
  count = var.enable_nat_gateway ? (var.single_nat_gateway ? 1 : length(var.private_subnet_cidrs)) : 0

  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = var.single_nat_gateway ? aws_nat_gateway.this[0].id : aws_nat_gateway.this[count.index % local.nat_gateway_count].id
}

resource "aws_route_table_association" "private" {
  count = length(var.private_subnet_cidrs)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = var.single_nat_gateway ? aws_route_table.private[0].id : aws_route_table.private[count.index % length(aws_route_table.private)].id
}

##############################################
# VPC Flow Logs
##############################################
resource "aws_cloudwatch_log_group" "flow_logs" {
  count             = var.enable_flow_logs ? 1 : 0
  name              = "/aws/vpc/${var.environment}/flow-logs"
  retention_in_days = var.flow_logs_retention_days

  tags = local.common_tags
}

resource "aws_iam_role" "flow_logs" {
  count = var.enable_flow_logs ? 1 : 0
  name  = "flow-logs-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "vpc-flow-logs.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = local.common_tags
}

resource "aws_iam_role_policy" "flow_logs" {
  count = var.enable_flow_logs ? 1 : 0
  name  = "flow-logs-policy-${var.environment}"
  role  = aws_iam_role.flow_logs[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams"
      ]
      Resource = "*"
    }]
  })
}

resource "aws_flow_log" "this" {
  count = var.enable_flow_logs ? 1 : 0

  vpc_id          = aws_vpc.this.id
  traffic_type    = "ALL"
  iam_role_arn    = aws_iam_role.flow_logs[0].arn
  log_destination = aws_cloudwatch_log_group.flow_logs[0].arn

  tags = merge(local.common_tags, {
    Name = "flow-logs-${var.environment}"
  })
}

