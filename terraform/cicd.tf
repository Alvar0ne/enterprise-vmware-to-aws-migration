# ============================================================
# GITHUB ACTIONS - OIDC PROVIDER
# Permite que GitHub Actions se autentique en AWS mediante OIDC
# sin almacenar Access Keys permanentes en GitHub.
# ============================================================

resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com"
  ]
}

# ============================================================
# GITHUB ACTIONS - IAM ROLE
# Rol asumido por GitHub Actions mediante OIDC.
# Compatible con el formato inmutable de subject de GitHub,
# que incluye los IDs permanentes del owner y repositorio.
# ============================================================

resource "aws_iam_role" "github_actions" {
  name = "${var.project_name}-github-actions"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Federated = aws_iam_openid_connect_provider.github.arn
        }

        Action = "sts:AssumeRoleWithWebIdentity"

        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }

          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:Alvar0ne@*/distrito-vmware-aws@*:ref:refs/heads/main"
          }
        }
      }
    ]
  })
}

# ============================================================
# GITHUB ACTIONS - ECR PERMISSIONS
# Permite al pipeline autenticarse en ECR y subir nuevas
# imágenes Docker de la aplicación.
# ============================================================

resource "aws_iam_role_policy" "github_actions_ecr" {
  name = "github-actions-ecr"
  role = aws_iam_role.github_actions.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "ecr:GetAuthorizationToken"
        ]

        Resource = "*"
      },
      {
        Effect = "Allow"

        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:CompleteLayerUpload",
          "ecr:InitiateLayerUpload",
          "ecr:PutImage",
          "ecr:UploadLayerPart"
        ]

        Resource = aws_ecr_repository.app.arn
      }
    ]
  })
}


# ============================================================
# GITHUB ACTIONS - AUTO SCALING DEPLOY PERMISSIONS
# Permite al pipeline iniciar y consultar un Instance Refresh
# para desplegar la nueva imagen Docker en las instancias EC2.
# ============================================================

resource "aws_iam_role_policy" "github_actions_deploy" {
  name = "github-actions-deploy"
  role = aws_iam_role.github_actions.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "autoscaling:StartInstanceRefresh",
          "autoscaling:DescribeInstanceRefreshes",
          "autoscaling:DescribeAutoScalingGroups"
        ]

        Resource = "*"
      }
    ]
  })
}