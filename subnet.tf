resource "aws_subnet" "subnet_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.0.0/22"
  availability_zone       = "us-east-2a"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "subnet_b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.4.0/22"
  availability_zone       = "us-east-2b"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "subnet_c" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.8.0/22"
  availability_zone       = "us-east-2c"
  map_public_ip_on_launch = true
}