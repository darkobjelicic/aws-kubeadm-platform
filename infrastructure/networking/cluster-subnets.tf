resource "aws_subnet" "cluster_public" {
  vpc_id                  = aws_vpc.cluster.id
  cidr_block              = "172.16.0.0/24"
  availability_zone       = "eu-central-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "kubeadm-platform-public"
  }
}

resource "aws_subnet" "cluster_private" {
  vpc_id                  = aws_vpc.cluster.id
  cidr_block              = "172.16.1.0/24"
  availability_zone       = "eu-central-1a"
  map_public_ip_on_launch = false

  tags = {
    Name = "kubeadm-platform-private"
  }
}
