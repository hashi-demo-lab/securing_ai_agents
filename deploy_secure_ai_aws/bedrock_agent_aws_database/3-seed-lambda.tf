data "archive_file" "seed_lambda" {
  type        = "zip"
  source_file = "./src/database-seed-lambda/index.py"
  output_path = "./src/zipped/seed_lambda_function.zip"
}

resource "aws_lambda_function" "seed" {
  function_name    = "seed-city-food-database"
  description      = "Seeds the RDS database with some initial data"
  runtime          = "python3.10"
  handler          = "index.lambda_handler"
  timeout          = 60
  memory_size      = 128
  role             = data.terraform_remote_state.vault_aws_auth.outputs.lambda_role_arn
  filename         = data.archive_file.seed_lambda.output_path
  source_code_hash = data.archive_file.seed_lambda.output_base64sha256
  layers           = [
    "arn:aws:lambda:${var.region}:634166935893:layer:vault-lambda-extension:14",
    aws_lambda_layer_version.aws-psycopg2.arn,
    aws_lambda_layer_version.rds_ssl.arn
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

resource "aws_cloudwatch_log_group" "seed_lambda" {
  name = "/aws/lambda/${aws_lambda_function.seed.function_name}"
}

# data "aws_lambda_invocation" "seed" {
#   depends_on = [ aws_iam_role_policy.lambda_cloudwatch ]

#   function_name = aws_lambda_function.seed.function_name

#   input = <<JSON
# {}
# JSON
# }