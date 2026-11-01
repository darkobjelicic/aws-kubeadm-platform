resource "aws_iam_role" "github_actions_startstop" {
  name = "github-actions-startstop"

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
            "token.actions.githubusercontent.com:sub" = "repo:darkobjelicic@116880434/aws-kubeadm-platform@1419832719:ref:refs/heads/main"
          }
        }
      }
    ]
  })
}

resource "aws_iam_policy" "github_actions_startstop" {
  name = "github-actions-startstop"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "DescribeAnyInstance"
        Effect   = "Allow"
        Action   = "ec2:DescribeInstances"
        Resource = "*"
      },
      {
        Sid      = "StopStartTaggedOnly"
        Effect   = "Allow"
        Action   = ["ec2:StopInstances", "ec2:StartInstances"]
        Resource = "arn:aws:ec2:eu-central-1:${data.aws_caller_identity.current.account_id}:instance/*"
        Condition = {
          StringEquals = {
            "aws:ResourceTag/Project" = "aws-kubeadm-platform"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "github_actions_startstop" {
  role       = aws_iam_role.github_actions_startstop.name
  policy_arn = aws_iam_policy.github_actions_startstop.arn
}
