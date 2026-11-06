resource "aws_instance" "worker" {
  count = 2

  ami                    = data.aws_ami.ubuntu_arm64.id
  instance_type          = "t4g.small"
  subnet_id              = data.terraform_remote_state.networking.outputs.private_subnet_id
  vpc_security_group_ids = [data.terraform_remote_state.networking.outputs.worker_security_group_id]
  iam_instance_profile   = aws_iam_instance_profile.node_ssm.name

  metadata_options {
    http_tokens = "required"
  }

  root_block_device {
    encrypted   = true
    volume_size = 20
  }

  tags = {
    Name = "kubeadm-platform-worker-${count.index + 1}"
  }
}
