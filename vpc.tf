resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  tags = {
    Name        = "${var.environment}-eks-vpc"
    Environment = var.environment
    ManagedBy   = "terraform"
    Project     = "eks"
  }
}

# Elastic IP for NAT Gateway
resource "aws_eip" "nat_eip" {
  domain = "vpc"

  tags = {
    Name        = "${var.environment}-nat-eip"
    Environment = var.environment
    ManagedBy   = "terraform"
    Project     = "eks"
  }
}

# -----------------------------
# PUBLIC SUBNETS
# -----------------------------

resource "aws_subnet" "public_1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_1_cidr
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true

  tags = {
    Name                     = "${var.environment}-public-subnet-1"
    "kubernetes.io/role/elb" = "1"
    "kubernetes.io/cluster/prod-eks-cluster" = "shared"


    Environment = var.environment
    ManagedBy   = "terraform"
    Project     = "eks"
  }
}

resource "aws_subnet" "public_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_2_cidr
  availability_zone       = "ap-south-1b"
  map_public_ip_on_launch = true

  tags = {
    Name                     = "${var.environment}-public-subnet-2"
    "kubernetes.io/role/elb" = "1"

    Environment = var.environment
    ManagedBy   = "terraform"
    Project     = "eks"
  }
}

# -----------------------------
# PRIVATE SUBNETS
# -----------------------------

resource "aws_subnet" "private_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_1_cidr
  availability_zone = "ap-south-1a"

  tags = {
    Name                              = "${var.environment}-private-subnet-1"
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/prod-eks-cluster" = "shared"


    Environment = var.environment
    ManagedBy   = "terraform"
    Project     = "eks"
  }
}

resource "aws_subnet" "private_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_2_cidr
  availability_zone = "ap-south-1b"

  tags = {
    Name                              = "${var.environment}-private-subnet-2"
    "kubernetes.io/role/internal-elb" = "1"

    Environment = var.environment
    ManagedBy   = "terraform"
    Project     = "eks"
  }
}

# -----------------------------
# INTERNET GATEWAY
# -----------------------------

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "${var.environment}-igw"
    Environment = var.environment
    ManagedBy   = "terraform"
    Project     = "eks"
  }
}

# -----------------------------
# NAT GATEWAY
# -----------------------------

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_1.id

  depends_on = [aws_internet_gateway.igw]

  tags = {
    Name        = "${var.environment}-nat-gateway"
    Environment = var.environment
    ManagedBy   = "terraform"
    Project     = "eks"
  }
}

# -----------------------------
# PUBLIC ROUTE TABLE
# -----------------------------

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "${var.environment}-public-rt"
    Environment = var.environment
    ManagedBy   = "terraform"
    Project     = "eks"
  }
}

resource "aws_route" "public_internet_access" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public_assoc_1" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_assoc_2" {
  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_route_table.public_rt.id
}

# -----------------------------
# PRIVATE ROUTE TABLE
# -----------------------------

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "${var.environment}-private-rt"
    Environment = var.environment
    ManagedBy   = "terraform"
    Project     = "eks"
  }
}

resource "aws_route" "private_nat_access" {
  route_table_id         = aws_route_table.private_rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}

resource "aws_route_table_association" "private_assoc_1" {
  subnet_id      = aws_subnet.private_1.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private_assoc_2" {
  subnet_id      = aws_subnet.private_2.id
  route_table_id = aws_route_table.private_rt.id
}