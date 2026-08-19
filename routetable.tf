resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

}

resource "aws_route" "tgw_route" {
  route_table_id            = aws_route_table.public.id
  destination_cidr_block    = "0.0.0.0/0"
  transit_gateway_id = aws_ec2_transit_gateway.transit_gateway.id
}

resource "aws_route_table_association" "subnet_a_route_table_assoc" {
  subnet_id      = aws_subnet.subnet_a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "subnet_b_route_table_assoc" {
  subnet_id      = aws_subnet.subnet_b.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "subnet_c_route_table_assoc" {
  subnet_id      = aws_subnet.subnet_c.id
  route_table_id = aws_route_table.public.id
}