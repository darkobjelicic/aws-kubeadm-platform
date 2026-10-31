provider "aws" {
  region = "eu-central-1"

  default_tags {
    tags = {
      Project   = "aws-kubeadm-platform"
      ManagedBy = "Terraform"
    }
  }
}
