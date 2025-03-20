#!/bin/sh
echo "Starting Vault Setup..."

# Install required packages
apk --no-cache add curl jq kubectl

export VAULT_CACERT=/vault/tls/ca.crt

echo "Detecting Vault pods..."
NUM_REPLICAS=$(kubectl get pods -n "$K8S_NAMESPACE" -l "app.kubernetes.io/name=vault" -o jsonpath='{.items[*].metadata.name}' | wc -w | tr -d ' ')
echo "Number of Vault pods detected: $NUM_REPLICAS"

# Use node 0 as the primary Vault instance.
export VAULT_ADDR=https://${VAULT_RELEASE_NAME}-0.${VAULT_RELEASE_NAME}-internal.${K8S_NAMESPACE}.svc.cluster.local:8200

# Check if Vault is already initialized.
init_status=$(curl --silent --insecure "$VAULT_ADDR/v1/sys/init" | jq -r '.initialized')

if [ "$init_status" = "true" ]; then
  if [ "$VAULT_MODE" = "auto_unseal" ]; then
    echo "Vault is already initialized, proceeding with unseal."
    # Retrieve existing credentials from the Kubernetes secret.
    root_token=$(kubectl get secret vault-init-credentials -n "$K8S_NAMESPACE" -o jsonpath='{.data.root-token}' | base64 -d)
    unseal_key=$(kubectl get secret vault-init-credentials -n "$K8S_NAMESPACE" -o jsonpath='{.data.unseal-key}' | base64 -d)
    # Unseal node 0.
    vault operator unseal "$unseal_key"
  else
    echo "Vault is already initialized. Waiting for auto-unseal..."
  fi
else
  if [ "$VAULT_MODE" = "auto_unseal" ]; then
    echo "Initializing Vault for the first time (manual unseal)..."
    init_output=$(vault operator init -key-shares=1 -key-threshold=1 -format=json)
    root_token=$(echo "$init_output" | jq -r '.root_token')
    unseal_key=$(echo "$init_output" | jq -r '.unseal_keys_b64[0]')
    
    # Unseal node 0.
    vault operator unseal "$unseal_key"
    
    export VAULT_TOKEN=$root_token
    vault audit enable file file_path=/vault/audit/vault_audit.log log_raw=true
  else
    echo "Initializing Vault for the first time (auto-unseal with recovery keys)..."
    init_output=$(vault operator init -recovery-shares=1 -recovery-threshold=1 -format=json)
    root_token=$(echo "$init_output" | jq -r '.root_token')
    
    export VAULT_TOKEN=$root_token
    vault audit enable file file_path=/vault/audit/vault_audit.log log_raw=true
  fi
fi

# For additional nodes, join the Raft cluster.
if [ "$NUM_REPLICAS" -gt 1 ]; then
  for i in $(seq 1 $((NUM_REPLICAS - 1))); do
    export VAULT_ADDR=https://${VAULT_RELEASE_NAME}-$i.${VAULT_RELEASE_NAME}-internal.${K8S_NAMESPACE}.svc.cluster.local:8200
    echo "Joining node $i to the Raft cluster..."
    vault operator raft join -leader-ca-cert="$(cat /vault/tls/ca.crt)" https://${VAULT_RELEASE_NAME}-0.${VAULT_RELEASE_NAME}-internal.${K8S_NAMESPACE}.svc.cluster.local:8200 || echo "Node $i already joined."
    
    if [ "$VAULT_MODE" = "auto_unseal" ]; then
      vault operator unseal "$unseal_key"
    fi
  done
fi

# For primary mode, wait until Vault becomes unsealed.
if [ "$VAULT_MODE" = "primary" ]; then
  echo "Waiting for Vault to become unsealed..."
  while true; do
    sealed=$(vault status -format=json | jq -r .sealed)
    if [ "$sealed" = "false" ]; then
      echo "Vault is unsealed."
      break
    else
      echo "Vault is still sealed. Waiting..."
      sleep 5
    fi
  done
fi

# Update the Kubernetes secret with Vault credentials.
kubectl apply -f - <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: vault-init-credentials
  namespace: $K8S_NAMESPACE
type: Opaque
data:
  root-token: $(echo -n "$root_token" | base64)
  unseal-key: $(echo -n "${unseal_key:-}" | base64)
EOF

echo "Vault setup complete. Credentials secret updated."
