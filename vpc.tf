# AWS::EC2::VPC AgentVPC
resource "aws_vpc" "agent" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.name_prefix}-${var.dagster_organization}-Agent"
  }
}

# AWS::EC2::InternetGateway InternetGateway
# AWS::EC2::VPCGatewayAttachment AttachGateway
resource "aws_internet_gateway" "agent" {
  vpc_id = aws_vpc.agent.id

  tags = {
    Name = "${var.name_prefix}-${var.dagster_organization}-Agent"
  }
}

# AWS::EC2::RouteTable PublicRouteTable
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.agent.id

  tags = {
    Name = "Public"
  }
}

# AWS::EC2::Route RouteToGateway
resource "aws_route" "to_gateway" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.agent.id
}

# AWS::EC2::Subnet AgentSubnetA / AgentSubnetB / AgentSubnetC
resource "aws_subnet" "agent" {
  count = length(var.subnet_cidrs)

  vpc_id                  = aws_vpc.agent.id
  cidr_block              = var.subnet_cidrs[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.name_prefix}-${var.dagster_organization}-Agent-${data.aws_availability_zones.available.names[count.index]}"
  }
}

# AWS::EC2::SubnetRouteTableAssociation PublicSubnet{A,B,C}RouteTableAssociation
resource "aws_route_table_association" "public" {
  count = length(aws_subnet.agent)

  subnet_id      = aws_subnet.agent[count.index].id
  route_table_id = aws_route_table.public.id
}
