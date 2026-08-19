resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  depends_on = [aws_vpc.main]
}

resource "aws_ec2_transit_gateway" "transit_gateway" {
  description = "transit_gateway"
}

resource "aws_ec2_transit_gateway_vpc_attachment" "example" {
  transit_gateway_id = aws_ec2_transit_gateway.transit_gateway.id
  vpc_id             = aws_vpc.main.id
  subnet_ids = [aws_subnet.subnet_a.id,aws_subnet.subnet_b.id,aws_subnet.subnet_c.id]
}
