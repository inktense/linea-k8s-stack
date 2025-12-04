# Linea Stack Helm Chart

A production-ready Helm chart for deploying a complete Linea blockchain stack on Kubernetes, including sequencer, maru, besu, and ethstats components.

## Introduction

This chart deploys a simplified Linea stack on a Kubernetes cluster using Helm. The stack consists of:

- **Sequencer**: Core blockchain sequencer node (Besu-based)
- **Maru**: Linea-specific component for transaction processing
- **Besu**: Ethereum client node with JSON-RPC and WebSocket interfaces
- **EthStats**: Network monitoring dashboard

## Prerequisites

- Kubernetes 1.19+
- Helm 3.0+
- kubectl configured to access your cluster
- Persistent storage support (StorageClass) for data persistence
- (Optional) Prometheus Operator for metrics scraping
- (Optional) S3-compatible storage for backups

## Installation

### Install from Local Chart

```bash
# Install from local chart directory
helm install my-linea ./helm/charts/linea-stack
```

### Install with Custom Values

```bash
# Create a custom values file
cat > my-values.yaml <<EOF
besu:
  service:
    type: LoadBalancer
  persistence:
    size: 100Gi
EOF

# Install with custom values
helm install my-linea ./helm/charts/linea-stack -f my-values.yaml
```

## Required Secrets

Before installation, create the required secrets for P2P keys:

```bash
# Sequencer P2P key
kubectl create secret generic linea-stack-sequencer-p2p-key \
  --from-file=key=/path/to/sequencer/key

# Maru P2P key
kubectl create secret generic linea-stack-maru-p2p-key \
  --from-file=key=/path/to/maru/key
```

**Note**: Update `sequencer.p2pKeySecretName` and `maru.p2pKeySecretName` in `values.yaml` if using different secret names.

### TX Sender Secrets (Production)

For production deployments, tx-sender requires a Kubernetes Secret with sensitive credentials:

```bash
# Create tx-sender secrets (REQUIRED for production)
kubectl create secret generic linea-stack-tx-sender-secrets \
  --from-literal=privateKey=0x... \
  --from-literal=toAddress=0x...
```

## Components

### Sequencer

The sequencer is the core component that sequences transactions. It runs as a StatefulSet with:
- Persistent storage for blockchain data
- Health probes (liveness and readiness)
- PodDisruptionBudget for high availability
- Metrics endpoint on port 9545

### Maru

Maru processes transactions in the Linea network. It runs as a StatefulSet with:
- Persistent storage for data
- Health probes (TCP-based)
- PodDisruptionBudget for high availability
- Metrics endpoint on port 9545

### Besu

Besu provides JSON-RPC and WebSocket interfaces. It runs as a StatefulSet with:
- Persistent storage for blockchain data
- LoadBalancer service for public access
- HorizontalPodAutoscaler for automatic scaling
- Health probes (liveness and readiness)
- Metrics endpoint on port 9545

### EthStats

EthStats provides a monitoring dashboard. It runs as a Deployment with:
- LoadBalancer service for public access
- WebSocket support for real-time updates

### TX Sender

TX Sender is a service that sends transactions to the blockchain at regular intervals. It runs as a Deployment with:
- Configurable transaction interval and amount
- Kubernetes Secrets for secure credential management
- Environment variable configuration

**Configuration:**
- `interval`: Seconds between transactions (default: 1)
- `amount`: Amount in wei to send (default: 10)
- `rpc.service`: RPC service to connect to (default: besu)
- `rpc.port`: RPC port (default: 8545)

**Security:**
- Uses Kubernetes Secrets for private keys and addresses (required for production)
- Supports development mode with plain text values (NOT for production)


## Monitoring

### Prometheus Integration

If you have Prometheus Operator installed:

```bash
# Install Prometheus Stack (if not already installed)
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

helm install monitoring prometheus-community/kube-prometheus-stack \
  --namespace monitoring --create-namespace \
  --set prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues=false

# Install Linea Stack with ServiceMonitor enabled
helm install my-linea ./helm/charts/linea-stack \
  --set metrics.serviceMonitor.enabled=true \
  --set metrics.serviceMonitor.namespace=monitoring
```

### View Metrics

```bash
# Port forward to Prometheus
kubectl -n monitoring port-forward svc/monitoring-kube-prometheus-prometheus 9090:9090

# Open Prometheus UI
open http://localhost:9090
```

## Health Checks

All components include health probes:

- **Sequencer**: HTTP GET on `/metrics` (port 9545)
- **Maru**: TCP socket check on port 8080
- **Besu**: HTTP GET on `/metrics` (port 9545)

Check pod health:

```bash
kubectl get pods
kubectl describe pod <pod-name>
```

## High Availability

### PodDisruptionBudgets

Sequencer and Maru have PodDisruptionBudgets configured to ensure at least 1 pod is always available during voluntary disruptions.

### Autoscaling

Besu includes a HorizontalPodAutoscaler that scales based on CPU and memory usage:
- Minimum replicas: 1
- Maximum replicas: 3
- CPU threshold: 70%
- Memory threshold: 70%

## Backups

### Setup

1. Create S3 credentials secret:
```bash
kubectl create secret generic linea-stack-backup-credentials \
  --from-literal=AWS_ACCESS_KEY_ID=your-key \
  --from-literal=AWS_SECRET_ACCESS_KEY=your-secret
```

2. Enable backups in values:
```yaml
backup:
  enabled: true
  storage:
    bucket: "my-backups"
    region: "us-east-1"
```

3. Install or upgrade:
```bash
helm upgrade --install my-linea ./helm/charts/linea-stack -f values.yaml
```

### Backup Schedule

Backups run on a cron schedule (default: every 6 hours). Check CronJob status:

```bash
kubectl get cronjobs
kubectl get jobs
kubectl logs job/<backup-job-name>
```

## Troubleshooting

### Pods Not Starting

```bash
# Check pod status
kubectl get pods

# Check pod logs
kubectl logs <pod-name>

# Check events
kubectl describe pod <pod-name>
```

### Common Issues

1. **Secrets not found**: Ensure P2P key secrets are created before installation
2. **Storage issues**: Verify StorageClass exists and PVCs are bound
3. **Service not accessible**: Check LoadBalancer status and firewall rules
4. **Metrics not scraping**: Verify ServiceMonitor namespace matches Prometheus namespace

### Besu Can't Connect to Sequencer

The Besu pod includes an init container that resolves the sequencer IP. If it fails:

```bash
# Check init container logs
kubectl logs <besu-pod-name> -c resolve-sequencer-ip

# Verify sequencer service is headless
kubectl get svc linea-stack-sequencer-svc
# Should show: clusterIP: None
```

### Maru Metrics Error

Maru has a known issue with its metrics endpoint (HTTP 500). The chart uses TCP probes as a workaround. This doesn't affect functionality.

## Uninstallation

```bash
# Uninstall the release
helm uninstall my-linea

# Delete PVCs (optional - removes all data)
kubectl delete pvc -l app=linea-stack

# Delete secrets (optional)
kubectl delete secret linea-stack-sequencer-p2p-key
kubectl delete secret linea-stack-maru-p2p-key
kubectl delete secret linea-stack-backup-credentials
```

