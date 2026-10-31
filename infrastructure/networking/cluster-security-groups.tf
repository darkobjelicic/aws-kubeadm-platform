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
  # trivy:ignore:AWS-0104 - nodes need broad outbound access for package updates,
  # container registry pulls (CDN-backed, non-enumerable IP ranges), and SSM.
  # Meaningful restriction would require VPC endpoints / an egress filtering proxy,
  # disproportionate for this lab. All egress funnels through a single NAT instance,
  # which is the natural future chokepoint if egress filtering is ever added.
  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"
  description = "Allow all outbound traffic"
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
  # trivy:ignore:AWS-0104 - NAT instance must reach arbitrary internet destinations
  # on behalf of private-subnet nodes (registries, package repos, SSM). This is its
  # entire purpose; restricting it would break the nodes it exists to serve.
  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"
  description = "Allow all outbound traffic to the internet"
}