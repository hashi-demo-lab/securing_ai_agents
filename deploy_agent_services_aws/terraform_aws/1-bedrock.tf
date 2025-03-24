data "aws_iam_policy_document" "bedrock_trust" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["bedrock.${data.aws_partition.current.dns_suffix}"]
      type        = "Service"
    }
    condition {
      test     = "StringEquals"
      values   = [data.aws_caller_identity.current.account_id]
      variable = "aws:SourceAccount"
    }
    condition {
      test     = "ArnLike"
      values   = ["arn:${data.aws_partition.current.partition}:bedrock:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:agent/*"]
      variable = "AWS:SourceArn"
    }
  }
}

data "aws_iam_policy_document" "bedrock_invoke_model" {
  statement {
    actions = ["bedrock:InvokeModel"]
    resources = [
      "arn:${data.aws_partition.current.partition}:bedrock:${data.aws_region.current.name}::foundation-model/amazon.titan-text-premier-v1:0",
    ]
  }
}

resource "aws_iam_role" "bedrock_agent" {
  assume_role_policy = data.aws_iam_policy_document.bedrock_trust.json
  name_prefix        = "AmazonBedrockExecutionRoleForAgents_"
}

resource "aws_iam_role_policy" "bedrock_agent" {
  policy = data.aws_iam_policy_document.bedrock_invoke_model.json
  role   = aws_iam_role.bedrock_agent.id
}

resource "aws_bedrockagent_agent" "this" {
  agent_name                  = "bedrock-agent-basic-lambda-no-api"
  agent_resource_role_arn     = aws_iam_role.bedrock_agent.arn
  description                 = "bedrock agent for Lambda function that returns static content"
  idle_session_ttl_in_seconds = 500
  foundation_model            = var.foundation_model
  instruction                 = "you are a helpful agent tasked to answer questions about the best foods to try depending on the city that specified."
}

resource "aws_bedrockagent_agent_action_group" "example" {
  action_group_name          = "city-food-action-group"
  description                = "invokes a Lambda function, passing in the city to get the recommended food"
  agent_id                   = aws_bedrockagent_agent.this.id
  agent_version              = "DRAFT"
  skip_resource_in_use_check = true

  action_group_executor {
    lambda = aws_lambda_function.this.arn
  }

  function_schema {
    member_functions {
      functions {
        name        = "city-food-action-group"
        description = "recommends food depending on the city specified"
        parameters {
          map_block_key = "city"
          type          = "string"
          description   = "City that users want to find out the best food for"
          required      = true
        }
      }
    }
  }
}