data "terraform_remote_state" "networking" {
  backend = "s3"
  config = {
    bucket = "devopsgeek-tfstate-942893240157"
    key    = "kubeadm-platform/networking/terraform.tfstate"
    region = "eu-central-1"
  }
}

data "aws_ami" "ubuntu_arm64" {
  most_recent = true
  owners      = ["099720109477"] # Canonical's official AWS account

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-arm64-server-*"]
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
