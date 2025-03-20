# Vault and Kubernetes Setup for Terraform Cloud JWT Authentication

This setup provisions a secure infrastructure on Kubernetes using Vault to authenticate Terraform Cloud workspaces via JWT. The setup includes Vault, monitoring, LDAP services, and Kubernetes namespaces managed by Terraform.

## Prerequisites

- **Docker Desktop with Kubernetes Enabled**: Runs the Kubernetes cluster on your local machine.
- **Helm**: For deploying Vault, Prometheus, Grafana, and other services.
- **Vault**: Deployed via Helm within Kubernetes.

## Components

### 1. **Kubernetes Namespaces**

We create individual namespaces for each service (Vault, LDAP, Prometheus, Grafana, etc.) dynamically using Terraform. This approach ensures isolation and organized management of resources.

### 2. **CA and Vault TLS Setup**

Vault’s TLS setup uses a CA to sign certificates for secure communication:
- A custom CA is generated and stored.
- Vault’s certificate and key are generated using the CA and stored in Kubernetes secrets, securing Vault communications.

### 3. **Vault Initialization Script**

A ConfigMap stores the `vault-init.sh` script, used by a Kubernetes job for initializing Vault:
- Initializes Vault and retrieves the root token and unseal key.
- Unseals Vault nodes and configures Raft storage for high availability.
- Creates a Kubernetes secret with the root token and unseal key for future reference.

The job relies on Helm to ensure Vault is fully deployed before initialization.

### 5. **LDAP Deployment**

OpenLDAP and phpLDAPadmin are deployed using Kubernetes manifests for managing users and groups within the cluster. Configuration data is provided via ConfigMaps and Secrets.

### 6. **Monitoring with Prometheus and Grafana**

- **Prometheus**: Monitors Vault and other services using Helm for deployment. The Prometheus scrape configuration is stored in a Kubernetes ConfigMap.
- **Grafana**: Deployed via Helm, with a ConfigMap-based data source configuration to visualize metrics from Prometheus.

Both Prometheus and Grafana access Vault securely using JWT-based secrets.


Dependencies ensure that secrets, ConfigMaps, and other Kubernetes resources are correctly set before deploying each service.

## Deployment Sequence

1. **Namespaces**: Create namespaces for Vault, LDAP, Prometheus, Grafana, etc.
2. **TLS Setup**: Generate and store CA and Vault certificates in Kubernetes secrets.
3. **Vault Deployment**: Deploy Vault with Helm and initialize it with the `vault-init.sh` script.
4. **Monitoring Setup**: Deploy Prometheus and Grafana for monitoring.
5. **LDAP Services**: Deploy OpenLDAP and phpLDAPadmin for user management.

## Usage

Run the following commands to initialize and apply the Terraform configuration:

```bash
terraform init
terraform apply