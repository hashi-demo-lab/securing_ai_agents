#!/bin/sh
set -e

echo "Configuring auto-unseal vault cluster..."

# Ensure required environment variables are set.
: "${VAULT_ADDR:?VAULT_ADDR must be set}"
: "${VAULT_TOKEN:?VAULT_TOKEN must be set}"
: "${VAULT_CACERT:?VAULT_CACERT must be set}"

# Transit key name (can be overridden via AUTO_UNSEAL_KEY_NAME)
KEY_NAME=${AUTO_UNSEAL_KEY_NAME:-autounseal}
echo "Using transit key name: $KEY_NAME"

# Install required packages.
apk --no-cache add curl jq kubectl

# Enable the transit secrets engine; ignore error if already enabled.
vault secrets enable transit || echo "Transit already enabled"

# Create the transit key; ignore error if it already exists.
vault write -f transit/keys/$KEY_NAME || echo "Transit key already exists"

# Write a god-access policy for testing
vault policy write autounseal - <<EOF
path "*" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}
EOF

echo "Creating orphan periodic token with policy 'autounseal'..."

# Create an orphan periodic token (without wrapping) with a short period for testing.
TOKEN_JSON=$(vault token create -orphan -policy="autounseal" -period=525600m -format=json)
UNWRAPPED_TOKEN=$(echo "$TOKEN_JSON" | jq -r .auth.client_token)
echo "Created token: '$UNWRAPPED_TOKEN'"

if [ -z "$UNWRAPPED_TOKEN" ]; then
  echo "Error: Token is empty. Exiting."
  exit 1
fi

# Base64 encode the token (remove any newlines).
TOKEN_BASE64=$(echo -n "$UNWRAPPED_TOKEN" | base64 | tr -d '\n')
echo "Token base64: '$TOKEN_BASE64'"

# Create (or update) a Kubernetes secret named "vault-seal-token" with the auto-unseal token.
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: vault-seal-token
  namespace: ${VAULT_NAMESPACE}
type: Opaque
data:
  token: "$TOKEN_BASE64"
EOF

# --- New Section: Enable and Configure Kubernetes Auth Method ---

echo "Enabling Kubernetes auth method..."
vault auth enable kubernetes || echo "Kubernetes auth method already enabled"

echo "Configuring Kubernetes auth method..."
vault write auth/kubernetes/config \
  kubernetes_host="https://kubernetes.docker.internal:6443" \
  kubernetes_ca_cert=@/var/run/secrets/kubernetes.io/serviceaccount/ca.crt

echo "Creating Kubernetes auth role 'auto-unseal'..."
vault write auth/kubernetes/role/auto-unseal \
  bound_service_account_names="*" \
  bound_service_account_namespaces="primary-vault" \
  token_policies="autounseal" \
  ttl="24h"

echo "Enabling KV v2 secrets engine at path 'secret'..."
vault secrets enable -path=secret kv-v2 || echo "KV v2 secrets engine already enabled"

echo "Writing test secret to secret/data/demo..."
vault kv put secret/demo username="demo-user" password="demo-password"

echo "Test KV secret 'secret/demo' configured."


echo "Auto-unseal vault cluster configuration complete."
