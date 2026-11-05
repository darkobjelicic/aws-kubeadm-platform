resource "aws_security_group" "control_plane" {
  name        = "kubeadm-platform-control-plane"
  description = "Security group for the kubeadm control plane node"
  vpc_id      = aws_vpc.cluster.id

  tags = {
    Name = "kubeadm-platform-control-plane"
  }
}

resource "aws_security_group" "worker" {
  name        = "kubeadm-platform-worker"
  description = "Security group for kubeadm worker nodes"
  vpc_id      = aws_vpc.cluster.id

  tags = {
    Name = "kubeadm-platform-worker"
  }
}

resource "aws_vpc_security_group_ingress_rule" "control_plane_api_from_worker" {
  security_group_id            = aws_security_group.control_plane.id
  referenced_security_group_id = aws_security_group.worker.id
  from_port                    = 6443
  to_port                      = 6443
  ip_protocol                  = "tcp"
  description                  = "Kubernetes API server, reachable from workers"
}

resource "aws_vpc_security_group_ingress_rule" "control_plane_api_from_self" {
  security_group_id            = aws_security_group.control_plane.id
  referenced_security_group_id = aws_security_group.control_plane.id
  from_port                    = 6443
  to_port                      = 6443
  ip_protocol                  = "tcp"
  description                  = "Kubernetes API server, reachable from other control plane nodes (future HA join)"
}

resource "aws_vpc_security_group_ingress_rule" "control_plane_etcd" {
  security_group_id            = aws_security_group.control_plane.id
  referenced_security_group_id = aws_security_group.control_plane.id
  from_port                    = 2379
  to_port                      = 2380
  ip_protocol                  = "tcp"
  description                  = "etcd client/peer traffic between control plane nodes (future HA)"
}

resource "aws_vpc_security_group_ingress_rule" "control_plane_kubelet" {
  security_group_id            = aws_security_group.control_plane.id
  referenced_security_group_id = aws_security_group.control_plane.id
  from_port                    = 10250
  to_port                      = 10250
  ip_protocol                  = "tcp"
  description                  = "Kubelet API, reached by the API server"
}

resource "aws_vpc_security_group_ingress_rule" "worker_kubelet_from_control_plane" {
  security_group_id            = aws_security_group.worker.id
  referenced_security_group_id = aws_security_group.control_plane.id
  from_port                    = 10250
  to_port                      = 10250
  ip_protocol                  = "tcp"
  description                  = "Kubelet API, reached by the API server for exec/logs/metrics"
}

resource "aws_vpc_security_group_ingress_rule" "worker_nodeport" {
  security_group_id = aws_security_group.worker.id
  cidr_ipv4          = aws_vpc.cluster.cidr_block
  from_port          = 30000
  to_port            = 32767
  ip_protocol        = "tcp"
  description        = "NodePort service range, reachable from within the VPC"
}

resource "aws_vpc_security_group_egress_rule" "control_plane_all" {
  security_group_id = aws_security_group.control_plane.id
  # See worker_all below for the same justification.
  # trivy:ignore:AWS-0104
  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"
  description = "Allow all outbound traffic"
}

resource "aws_vpc_security_group_egress_rule" "worker_all" {
  security_group_id = aws_security_group.worker.id
  # Nodes need broad outbound access for package updates, container registry
  # pulls (CDN-backed, non-enumerable IP ranges), and SSM. Meaningful restriction
  # would require VPC endpoints / an egress filtering proxy, disproportionate for
  # this lab. All egress funnels through a single NAT instance.
  # trivy:ignore:AWS-0104
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

resource "aws_vpc_security_group_ingress_rule" "nat_from_control_plane" {
  security_group_id            = aws_security_group.nat.id
  referenced_security_group_id = aws_security_group.control_plane.id
  ip_protocol                  = "-1"
  description                  = "Allow all traffic from control plane needing internet egress"
}

resource "aws_vpc_security_group_ingress_rule" "nat_from_worker" {
  security_group_id            = aws_security_group.nat.id
  referenced_security_group_id = aws_security_group.worker.id
  ip_protocol                  = "-1"
  description                  = "Allow all traffic from workers needing internet egress"
}

resource "aws_vpc_security_group_egress_rule" "nat_all" {
  security_group_id = aws_security_group.nat.id
  # NAT instance must reach arbitrary internet destinations on behalf of
  # private-subnet nodes (registries, package repos, SSM). This is its entire
  # purpose; restricting it would break the nodes it exists to serve.
  # trivy:ignore:AWS-0104
  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"
  description = "Allow all outbound traffic to the internet"
}