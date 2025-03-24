# Deploy agent services on AWS using Terraform

# Pre-reqs

Pre-req: Subscribe to EULA for Foundation Models - https://docs.aws.amazon.com/bedrock/latest/userguide/getting-started.html

# Deployment

Step 1: Determine if you would like to change the foundation model. Use the `foundation_model` variable to adjust the foundational model used for the Bedrock Agent. `amazon.titan-text-premier-v1:0` is used by default

Step 2: Run `terraform init` and `terraform apply` to deploy the code