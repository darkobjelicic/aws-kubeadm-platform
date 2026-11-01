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
        Sid      = "Ec2Scoped"
        Effect   = "Allow"
        Action   = concat(local.ec2_read_actions, local.ec2_write_actions)
        Resource = "*"
        Condition = {
          StringEquals = {
            "aws:RequestedRegion" = "eu-central-1"
          }
        }
      },
      {
        Sid      = "FlowLogDelivery"
        Effect   = "Allow"
        Action   = concat(local.logs_read_actions, local.logs_write_actions)
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
        Action = concat(local.iam_read_actions, [
          "iam:TagRole",
          "iam:PutRolePolicy",
          "iam:AttachRolePolicy",
          "iam:CreateInstanceProfile",
          "iam:TagInstanceProfile",
          "iam:AddRoleToInstanceProfile",
          "iam:DeleteRole",
          "iam:DetachRolePolicy",
          "iam:DeleteRolePolicy",
          "iam:RemoveRoleFromInstanceProfile",
          "iam:DeleteInstanceProfile",
          "iam:UntagRole",
        ])
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
