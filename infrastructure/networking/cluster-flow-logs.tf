resource "aws_flow_log" "cluster" {
  vpc_id               = aws_vpc.cluster.id
  log_destination_type = "s3"
  log_destination      = "arn:aws:s3:::devopsgeek-log-archive-771574032277/kubeadm-platform/vpc-flow-logs"
  traffic_type         = "ALL"

  tags = {
    Name = "kubeadm-platform-flow-log"
  }
}
