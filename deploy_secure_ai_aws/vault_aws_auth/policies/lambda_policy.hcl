# Allow Lambda to read secrets from specific paths
path "kv/data/test" {
  capabilities = ["read"]
}

# Allow Lambda to read specific metadata
path "kv/metadata/test" {
  capabilities = ["read", "list"]
}

# Allow Lambda to renew its token
path "auth/token/renew-self" {
  capabilities = ["update"]
}

# Allow Lambda to lookup its token information
path "auth/token/lookup-self" {
  capabilities = ["read"]
}