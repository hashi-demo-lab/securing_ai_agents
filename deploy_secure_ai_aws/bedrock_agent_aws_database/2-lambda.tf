data "aws_iam_policy_document" "lambda_trust" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["lambda.${data.aws_partition.current.dns_suffix}"]
      type        = "Service"
    }
    condition {
      test     = "StringEquals"
      values   = [data.aws_caller_identity.current.account_id]
      variable = "aws:SourceAccount"
    }
  }
}

data "aws_iam_policy_document" "lambda_cloudwatch" {
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "${aws_cloudwatch_log_group.lambda.arn}:*",
      "${aws_cloudwatch_log_group.seed_lambda.arn}:*", # For seed Lambda
    ]
  }
}

data "aws_iam_policy_document" "lambda_vault" {
  statement {
    actions = [
      "kms:Decrypt",
      "kms:RetireGrant"
    ]
    resources = [
      "*" # TODO: Tighten
    ]
  }

  statement {
    actions = [
      "sts:GetCallerIdentity"
    ]
    resources = [
      "*"
    ]
  }
}

resource "aws_iam_role_policy" "lambda_cloudwatch" {
  policy = data.aws_iam_policy_document.lambda_cloudwatch.json
  role   = data.terraform_remote_state.vault_aws_auth.outputs.lambda_role_id
}

resource "aws_iam_role_policy" "lambda_vault" {
  policy = data.aws_iam_policy_document.lambda_vault.json
  role   = data.terraform_remote_state.vault_aws_auth.outputs.lambda_role_id
}

data "archive_file" "aws-psycopg2_layer_zip" {
  type        = "zip"
  source_dir  = "./dependencies/aws-psycopg2"
  output_path = "./dependencies/zipped/aws-psycopg2.zip"
}

resource "aws_lambda_layer_version" "aws-psycopg2" {
  filename            = data.archive_file.aws-psycopg2_layer_zip.output_path
  layer_name          = "aws-psycopg2-python"
  compatible_runtimes = ["python3.10"]

  source_code_hash = data.archive_file.aws-psycopg2_layer_zip.output_base64sha256
}

data "archive_file" "rds_ssl_zip" {
  type        = "zip"
  source_dir  = "./dependencies/rds-ssl"
  output_path = "./dependencies/zipped/rds-ssl.zip"
}

resource "aws_lambda_layer_version" "rds_ssl" {
  filename            = data.archive_file.rds_ssl_zip.output_path
  layer_name          = "rds-ssl-python"
  compatible_runtimes = ["python3.10"]

  source_code_hash = data.archive_file.rds_ssl_zip.output_base64sha256
}

data "archive_file" "lambda_function" {
  type        = "zip"
  source_file = "./src/food-lambda/index.py"
  output_path = "./src/zipped/lambda_function.zip"
}

resource "aws_lambda_function" "this" {
  function_name    = "city-food-recommendation"
  description      = "Takes in Bedrock request and returns formatted Bedrock response for food recommendation in a specified city"
  runtime          = "python3.10"
  handler          = "index.lambda_handler"
  timeout          = 60
  memory_size      = 128
  role             = data.terraform_remote_state.vault_aws_auth.outputs.lambda_role_arn
  filename         = data.archive_file.lambda_function.output_path
  source_code_hash = data.archive_file.lambda_function.output_base64sha256
  layers           = [
    "arn:aws:lambda:${var.region}:634166935893:layer:vault-lambda-extension:14",
    aws_lambda_layer_version.aws-psycopg2.arn
  ]

  environment {
    variables = {
      LOG_LEVEL            = "INFO",
      VAULT_ADDR           = var.vault_addr,
      VAULT_AUTH_ROLE      = data.terraform_remote_state.vault_aws_auth.outputs.lambda_role_id,
      VAULT_AUTH_PROVIDER  = "aws",
      VAULT_SECRET_PATH_DB = data.terraform_remote_state.vault_aws_auth.outputs.vault_secret_path_db,
      VAULT_SECRET_FILE_DB = "/tmp/vault_secret.json",
      VAULT_NAMESPACE      = "admin",
      DATABASE_URL         = data.terraform_remote_state.vault_aws_auth.outputs.rds_address,
    }
  }
}

resource "aws_cloudwatch_log_group" "lambda" {
  name = "/aws/lambda/${aws_lambda_function.this.function_name}"
}

resource "aws_lambda_permission" "bedrock_agent" {
  statement_id  = "agentsInvokeFunction"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.function_name
  principal     = "bedrock.${data.aws_partition.current.dns_suffix}"

  source_arn = aws_bedrockagent_agent.this.agent_arn
}