data "aws_ami" "amazon_linux_arm64" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-arm64"]
  }

  filter {
    name   = "architecture"
    values = ["arm64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_iam_role" "nat_ssm" {
  name = "kubeadm-platform-nat-ssm"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
  permissions_boundary = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "nat_ssm" {
  role       = aws_iam_role.nat_ssm.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "nat_ssm" {
  name = "kubeadm-platform-nat-ssm"
  role = aws_iam_role.nat_ssm.name
}

resource "aws_instance" "cluster_nat" {
  ami                    = data.aws_ami.amazon_linux_arm64.id
  instance_type          = "t4g.nano"
  subnet_id              = aws_subnet.cluster_public.id
  iam_instance_profile   = aws_iam_instance_profile.nat_ssm.name
  vpc_security_group_ids = [aws_security_group.nat.id]
  source_dest_check      = false

  metadata_options {
    http_tokens = "required"
  }

  root_block_device {
    encrypted = true
  }

  tags = {
    Name = "kubeadm-platform-nat"
  }

  #  lifecycle {
  #    ignore_changes = [ami]
  #  }
}
