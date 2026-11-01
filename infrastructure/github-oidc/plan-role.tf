resource "aws_iam_role" "github_actions_plan" {
  name = "github-actions-plan"

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
          }
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:darkobjelicic@116880434/aws-kubeadm-platform@1419832719:*"
          }
        }
      }
    ]
  })
}

resource "aws_iam_policy" "github_actions_plan_ec2" {
  name = "github-actions-plan-ec2"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "Ec2ReadOnly"
        Effect   = "Allow"
        Action   = local.ec2_read_actions
        Resource = "*"
        Condition = {
          StringEquals = {
            "aws:RequestedRegion" = "eu-central-1"
          }
        }
      },
      {
        Sid      = "FlowLogDeliveryReadOnly"
        Effect   = "Allow"
        Action   = local.logs_read_actions
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_policy" "github_actions_plan_iam" {
  name = "github-actions-plan-iam"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "IamReadOnlyScoped"
        Effect = "Allow"
        Action = local.iam_read_actions
        Resource = [
          "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/kubeadm-platform-*",
          "arn:aws:iam::${data.aws_caller_identity.current.account_id}:instance-profile/kubeadm-platform-*",
        ]
      }
    ]
  })
}

resource "aws_iam_policy" "github_actions_plan_s3" {
  name = "github-actions-plan-s3"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "StateReadOnly"
        Effect   = "Allow"
        Action   = "s3:GetObject"
        Resource = "arn:aws:s3:::devopsgeek-tfstate-942893240157/kubeadm-platform/*"
      },
      {
        Sid    = "LockFileOnly"
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:DeleteObject",
        ]
        Resource = "arn:aws:s3:::devopsgeek-tfstate-942893240157/kubeadm-platform/*.tflock"
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

resource "aws_iam_role_policy_attachment" "github_actions_plan_ec2" {
  role       = aws_iam_role.github_actions_plan.name
  policy_arn = aws_iam_policy.github_actions_plan_ec2.arn
}

resource "aws_iam_role_policy_attachment" "github_actions_plan_iam" {
  role       = aws_iam_role.github_actions_plan.name
  policy_arn = aws_iam_policy.github_actions_plan_iam.arn
}

resource "aws_iam_role_policy_attachment" "github_actions_plan_s3" {
  role       = aws_iam_role.github_actions_plan.name
  policy_arn = aws_iam_policy.github_actions_plan_s3.arn
}
