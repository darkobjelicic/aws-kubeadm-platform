data "aws_caller_identity" "current" {}

data "tls_certificate" "github_actions" {
  url = "https://token.actions.githubusercontent.com"
}

resource "aws_iam_openid_connect_provider" "github_actions" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.github_actions.certificates[0].sha1_fingerprint]
}

# Shared action lists for the plan/apply roles' policies, so read-only actions
# never drift out of sync between the two (both roles refresh state the same
# way - only apply needs the write-side actions on top).
locals {
  ec2_read_actions = [
    "ec2:DescribeVpcs", "ec2:DescribeVpcAttribute",
    "ec2:DescribeSubnets",
    "ec2:DescribeInternetGateways",
    "ec2:DescribeRouteTables",
    "ec2:DescribeSecurityGroups", "ec2:DescribeSecurityGroupRules",
    "ec2:DescribeInstances", "ec2:DescribeInstanceAttribute",
    "ec2:DescribeVolumes", "ec2:DescribeInstanceCreditSpecifications",
    "ec2:DescribeIamInstanceProfileAssociations",
    "ec2:DescribeTags",
    "ec2:DescribeImages", "ec2:DescribeAvailabilityZones", "ec2:DescribeNetworkInterfaces", "ec2:DescribeInstanceTypes",
    "ec2:DescribeFlowLogs",
  ]

  ec2_write_actions = [
    "ec2:CreateVpc", "ec2:DeleteVpc", "ec2:ModifyVpcAttribute",
    "ec2:CreateSubnet", "ec2:DeleteSubnet", "ec2:ModifySubnetAttribute",
    "ec2:CreateInternetGateway", "ec2:DeleteInternetGateway", "ec2:AttachInternetGateway", "ec2:DetachInternetGateway",
    "ec2:CreateRouteTable", "ec2:DeleteRouteTable", "ec2:CreateRoute", "ec2:DeleteRoute", "ec2:ReplaceRoute", "ec2:AssociateRouteTable", "ec2:DisassociateRouteTable",
    "ec2:CreateSecurityGroup", "ec2:DeleteSecurityGroup",
    "ec2:AuthorizeSecurityGroupIngress", "ec2:AuthorizeSecurityGroupEgress",
    "ec2:RevokeSecurityGroupIngress", "ec2:RevokeSecurityGroupEgress",
    "ec2:RunInstances", "ec2:TerminateInstances", "ec2:StopInstances", "ec2:StartInstances",
    "ec2:ModifyInstanceAttribute",
    "ec2:AssociateIamInstanceProfile", "ec2:DisassociateIamInstanceProfile",
    "ec2:ModifyNetworkInterfaceAttribute",
    "ec2:CreateTags", "ec2:DeleteTags",
    "ec2:CreateFlowLogs", "ec2:DeleteFlowLogs",
  ]

  logs_read_actions = [
    "logs:DescribeLogGroups",
    "logs:ListLogDeliveries",
    "logs:GetLogDelivery",
  ]

  logs_write_actions = [
    "logs:CreateLogDelivery",
    "logs:DeleteLogDelivery",
  ]

  iam_read_actions = [
    "iam:GetRole",
    "iam:GetInstanceProfile",
    "iam:ListRolePolicies",
    "iam:ListAttachedRolePolicies",
    "iam:ListInstanceProfilesForRole",
  ]
}

