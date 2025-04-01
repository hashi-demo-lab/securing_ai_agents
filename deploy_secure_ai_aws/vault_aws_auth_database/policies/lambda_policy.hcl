# Allow Lambda to read secrets from the database creds paths
path "database/creds/lambda-function" {
    capabilities = ["read"]
}

# Allow Lambda to renew its token
path "auth/token/renew-self" {
  capabilities = ["update"]
}

# Allow Lambda to lookup its token information
path "auth/token/lookup-self" {
  capabilities = ["read"]
}