resource "aws_vpc" "cluster" {
    cidr_block       = "172.16.0.0/16"
    enable_dns_support    = true
    enable_dns_hostnames = true

    tags = {
        Name = "kubeadm-platform-cluster"
    }
}