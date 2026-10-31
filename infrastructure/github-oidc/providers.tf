provider "aws" {
  region  = "eu-central-1"
  profile = "kubeadm-platform-admin"

  default_tags {
    tags = {
      Project   = "aws-kubeadm-platform"
      ManagedBy = "Terraform"
    }
  }
}