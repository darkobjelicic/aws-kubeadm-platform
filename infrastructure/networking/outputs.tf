output "vpc_id" {
  value = aws_vpc.cluster.id
}

output "private_subnet_id" {
  value = aws_subnet.cluster_private.id
}

output "cluster_nodes_security_group_id" {
  value = aws_security_group.cluster_nodes.id
}
