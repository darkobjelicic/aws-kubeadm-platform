resource "aws_security_group" "cluster_nodes" {
  name        = "kubeadm-platform-cluster-nodes"
  description = "Security group for kubeadm control plane and worker nodes"
  vpc_id      = aws_vpc.cluster.id

  tags = {
    Name = "kubeadm-platform-cluster-nodes"
  }
}

resource "aws_vpc_security_group_ingress_rule" "cluster_nodes_self" {
  security_group_id            = aws_security_group.cluster_nodes.id
  referenced_security_group_id = aws_security_group.cluster_nodes.id
  ip_protocol                  = "-1"
  description                  = "Allow all traffic between cluster nodes (kubelet, CNI overlay, NodePort range)"
}

resource "aws_vpc_security_group_egress_rule" "cluster_nodes_all" {
  security_group_id = aws_security_group.cluster_nodes.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
  description       = "Allow all outbound traffic"
}

resource "aws_security_group" "nat" {
  name        = "kubeadm-platform-nat"
  description = "Security group for the NAT instance"
  vpc_id      = aws_vpc.cluster.id

  tags = {
    Name = "kubeadm-platform-nat"
  }
}

resource "aws_vpc_security_group_ingress_rule" "nat_from_cluster_nodes" {
  security_group_id            = aws_security_group.nat.id
  referenced_security_group_id = aws_security_group.cluster_nodes.id
  ip_protocol                  = "-1"
  description                  = "Allow all traffic from cluster nodes needing internet egress"
}

resource "aws_vpc_security_group_egress_rule" "nat_all" {
  security_group_id = aws_security_group.nat.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
  description       = "Allow all outbound traffic to the internet"
}