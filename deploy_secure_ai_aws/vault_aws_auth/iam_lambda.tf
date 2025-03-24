// Create IAM role for Lambda with Vault authentication
resource "aws_iam_role" "lambda" {
  name               = "${var.aws_environment_name}-lambda-role"
  assume_role_policy = var.assume_role ? data.aws_iam_policy_document.assume_role_lambda_plus_root[0].json : data.aws_iam_policy_document.assume_role_lambda.json
}

resource "aws_iam_instance_profile" "lambda" {
  name = "${var.aws_environment_name}-lambda-instance-profile"
  role = aws_iam_role.lambda.name
}

resource "aws_iam_role" "extra_role" {
  count              = var.assume_role ? 1 : 0
  name               = "${var.aws_environment_name}-extra-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_lambda_plus_root[0].json
}

resource "aws_iam_role_policy" "lambda" {
  name   = "${var.aws_environment_name}-lambda-policy"
  role   = aws_iam_role.lambda.id
  policy = var.assume_role ? data.aws_iam_policy_document.lambda_plus_assume_role[0].json : data.aws_iam_policy_document.lambda.json
}

resource "aws_iam_role_policy" "extra_role_policy" {
  count  = var.assume_role ? 1 : 0
  name   = "${var.aws_environment_name}-extra-role-policy"
  role   = aws_iam_role.extra_role[0].id
  policy = data.aws_iam_policy_document.lambda_plus_assume_role[0].json
}

data "aws_iam_policy_document" "assume_role_lambda" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "assume_role_lambda_plus_root" {
  count = var.assume_role ? 1 : 0

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    principals {
      type = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }
}
### THIS IS NOT RECOMMENDED FOR PRODUCTION USE ###
## workaround for Doormat ## Vault 
data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "aws_iam_policy" "demo_user_permissions_boundary" {
  name = "DemoUser"
}

data "aws_iam_policy" "security_compute_access" {
  name = "SecurityComputeAccess"
}

data "aws_iam_policy_document" "lambda" {
  statement {
    sid    = "LambdaLogs"
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = ["*"]
  }
}

data "aws_iam_policy_document" "lambda_plus_assume_role" {
  count = var.assume_role ? 1 : 0

  statement {
    sid    = "LambdaLogs"
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = ["*"]
  }

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    resources = ["*"]
  }
}


#### Vault

### THIS IS NOT RECOMMENDED FOR PRODUCTION USE ###
## workaround for Doormat ##

resource "aws_iam_user_policy_attachment" "vault_mount_user" {
  user       = aws_iam_user.vault_mount_user.name
  policy_arn = data.aws_iam_policy.demo_user_permissions_boundary.arn
}

locals {
  my_email = split("/", data.aws_caller_identity.current.arn)[2]
}

resource "aws_iam_user" "vault_mount_user" {
  name                 = "demo-${local.my_email}"
  permissions_boundary = data.aws_iam_policy.demo_user_permissions_boundary.arn
  force_destroy        = true
}

resource "aws_iam_access_key" "vault_mount_user" {
  user = aws_iam_user.vault_mount_user.name
}



# // Policy allowing Lambda to generate temporary credentials for Vault auth
# resource "aws_iam_policy" "lambda_vault_auth" {
#   name        = "${var.aws_environment_name}-lambda-vault-auth"
#   description = "Policy allowing Lambda to authenticate with Vault using AWS auth method"

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect   = "Allow"
#         Action   = "sts:GetCallerIdentity"
#         Resource = "*"
#       }
#     ]
#   })
# }

# // Attach the Vault auth policy to the Lambda role
# resource "aws_iam_role_policy_attachment" "lambda_vault_auth_attachment" {
#   role       = aws_iam_role.lambda.name
#   policy_arn = aws_iam_policy.lambda_vault_auth.arn
# }