resource "aws_iam_role" "github_actions_apply" {
  name = "github-actions-apply"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.github_actions.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
            "token.actions.githubusercontent.com:sub" = "repo:darkobjelicic@116880434/aws-kubeadm-platform@1419832719:environment:production"
          }
        }
      }
    ]
  })
}

resource "aws_iam_policy" "github_actions_apply_ec2" {
  name = "github-actions-apply-ec2"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Ec2Scoped"
        Effect = "Allow"
        Action = [
          "ec2:CreateVpc", "ec2:DeleteVpc", "ec2:ModifyVpcAttribute", "ec2:DescribeVpcs", "ec2:DescribeVpcAttribute",
          "ec2:CreateSubnet", "ec2:DeleteSubnet", "ec2:ModifySubnetAttribute", "ec2:DescribeSubnets",
          "ec2:CreateInternetGateway", "ec2:DeleteInternetGateway", "ec2:AttachInternetGateway", "ec2:DetachInternetGateway", "ec2:DescribeInternetGateways",
          "ec2:CreateRouteTable", "ec2:DeleteRouteTable", "ec2:CreateRoute", "ec2:DeleteRoute", "ec2:ReplaceRoute", "ec2:AssociateRouteTable", "ec2:DisassociateRouteTable", "ec2:DescribeRouteTables",
          "ec2:CreateSecurityGroup", "ec2:DeleteSecurityGroup",
          "ec2:AuthorizeSecurityGroupIngress", "ec2:AuthorizeSecurityGroupEgress",
          "ec2:RevokeSecurityGroupIngress", "ec2:RevokeSecurityGroupEgress",
          "ec2:DescribeSecurityGroups", "ec2:DescribeSecurityGroupRules",
          "ec2:RunInstances", "ec2:TerminateInstances", "ec2:StopInstances", "ec2:StartInstances",
          "ec2:DescribeInstances", "ec2:ModifyInstanceAttribute", "ec2:DescribeInstanceAttribute",
          "ec2:DescribeVolumes", "ec2:DescribeInstanceCreditSpecifications",
          "ec2:AssociateIamInstanceProfile", "ec2:DisassociateIamInstanceProfile", "ec2:DescribeIamInstanceProfileAssociations",
          "ec2:ModifyNetworkInterfaceAttribute",
          "ec2:CreateTags", "ec2:DeleteTags", "ec2:DescribeTags",
          "ec2:DescribeImages", "ec2:DescribeAvailabilityZones", "ec2:DescribeNetworkInterfaces", "ec2:DescribeInstanceTypes",
          "ec2:CreateFlowLogs", "ec2:DeleteFlowLogs", "ec2:DescribeFlowLogs",
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "aws:RequestedRegion" = "eu-central-1"
          }
        }
      },
      {
        Sid    = "FlowLogDelivery"
        Effect = "Allow"
        Action = [
          "logs:CreateLogDelivery",
          "logs:DeleteLogDelivery",
          "logs:DescribeLogGroups",
          "logs:ListLogDeliveries",
          "logs:GetLogDelivery",
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_policy" "github_actions_apply_iam" {
  name = "github-actions-apply-iam"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "IamRoleCreateScoped"
        Effect = "Allow"
        Action = "iam:CreateRole"
        Resource = [
          "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/kubeadm-platform-*",
        ]
        Condition = {
          StringEquals = {
            "iam:PermissionsBoundary" = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
          }
        }
      },
      {
        Sid    = "IamRoleManagementScoped"
        Effect = "Allow"
        Action = [
          "iam:TagRole",
          "iam:PutRolePolicy",
          "iam:AttachRolePolicy",
          "iam:CreateInstanceProfile",
          "iam:TagInstanceProfile",
          "iam:AddRoleToInstanceProfile",
          "iam:GetRole",
          "iam:GetInstanceProfile",
          "iam:ListRolePolicies",
          "iam:ListAttachedRolePolicies",
          "iam:ListInstanceProfilesForRole",
          "iam:DeleteRole",
          "iam:DetachRolePolicy",
          "iam:DeleteRolePolicy",
          "iam:RemoveRoleFromInstanceProfile",
          "iam:DeleteInstanceProfile",
          "iam:UntagRole",
        ]
        Resource = [
          "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/kubeadm-platform-*",
          "arn:aws:iam::${data.aws_caller_identity.current.account_id}:instance-profile/kubeadm-platform-*",
        ]
      },
      {
        Sid      = "IamPassRoleToEc2Only"
        Effect   = "Allow"
        Action   = "iam:PassRole"
        Resource = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/kubeadm-platform-*"
        Condition = {
          StringEquals = {
            "iam:PassedToService" = "ec2.amazonaws.com"
          }
        }
      },
      {
        Sid      = "DenySelfTampering"
        Effect   = "Deny"
        Action   = "iam:*"
        Resource = aws_iam_role.github_actions_apply.arn
      }
    ]
  })
}

resource "aws_iam_policy" "github_actions_apply_s3" {
  name = "github-actions-apply-s3"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "StateBucketObjectAccess"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
        ]
        Resource = "arn:aws:s3:::devopsgeek-tfstate-942893240157/kubeadm-platform/*"
      },
      {
        Sid      = "StateBucketListOwnPrefix"
        Effect   = "Allow"
        Action   = "s3:ListBucket"
        Resource = "arn:aws:s3:::devopsgeek-tfstate-942893240157"
        Condition = {
          StringLike = {
            "s3:prefix" = ["kubeadm-platform/*"]
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "github_actions_apply_ec2" {
  role       = aws_iam_role.github_actions_apply.name
  policy_arn = aws_iam_policy.github_actions_apply_ec2.arn
}

resource "aws_iam_role_policy_attachment" "github_actions_apply_iam" {
  role       = aws_iam_role.github_actions_apply.name
  policy_arn = aws_iam_policy.github_actions_apply_iam.arn
}

resource "aws_iam_role_policy_attachment" "github_actions_apply_s3" {
  role       = aws_iam_role.github_actions_apply.name
  policy_arn = aws_iam_policy.github_actions_apply_s3.arn
}
