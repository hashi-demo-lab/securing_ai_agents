# Get host IP for connecting to local services
HOST_IP=$(ip route get 1 | awk '{print $(NF-2);exit}')

# Run the container with connections to local services
docker run \
  --name vault-neo4j-sync-test \
  -e VAULT_URL="http://${HOST_IP}:8200" \
  -e VAULT_TOKEN="your-local-token" \
  -e NEO4J_URI="bolt://${NEO4J_HOST_IP}:7687" \
  -e NEO4J_USER="neo4j" \
  -e NEO4J_PASSWORD="Hashi123!" \
  vault-neo4j-sync:latest

# Check logs
docker logs -f vault-neo4j-sync-test