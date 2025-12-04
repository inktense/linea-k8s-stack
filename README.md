helm lint ./helm/charts/linea-stack  

helm template linea helm/charts/linea-stack



Orbstack
v0
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update



v1
kubectl create namespace monitoring
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

helm upgrade --install monitoring prometheus-community/kube-prometheus-stack \
  -n monitoring



helm upgrade --install monitoring prometheus-community/kube-prometheus-stack \
  --namespace monitoring --create-namespace \
  --set prometheus.enabled=true \
  --set prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues=false \
  --set prometheus.prometheusSpec.serviceMonitorSelector.matchLabels.release=monitoring




   kubectl create secret generic linea-stack-sequencer-p2p-key \
  --from-file=key=config/sequencer/key 

     kubectl create secret generic linea-stack-maru-p2p-key \
  --from-file=key=config/maru/key 

   kubectl create secret generic linea-stack-tx-sender-secrets \
  --from-literal=privateKey=0x... \
  --from-literal=toAddress=0x...

helm upgrade --install local helm/charts/linea-stack


Check Prometheus 

kubectl -n monitoring port-forward svc/monitoring-kube-prometheus-prometheus 9090

http://localhost:9090/targets

## Backup Configuration

The chart includes automated backups via CronJob that backs up sequencer, maru, and besu data to external storage.

### Setup Backup Credentials

Before enabling backups, create a secret with your S3 credentials:

```bash
kubectl create secret generic linea-stack-backup-credentials \
  --from-literal=AWS_ACCESS_KEY_ID=your-access-key \
  --from-literal=AWS_SECRET_ACCESS_KEY=your-secret-key
```

**For S3-compatible storage (MinIO, etc.):**
Use the same command format. The endpoint will be configured in values.yaml.

### Configure Backup in values.yaml

```yaml
backup:
  enabled: true
  schedule: "0 */6 * * *"  # Every 6 hours
  retention: 7  # Keep last 7 backups
  compression: true
  storage:
    bucket: "linea-backups"  # S3 bucket name
    endpoint: ""  # Optional: For S3-compatible (MinIO), e.g., "http://minio-service:9000"
    region: "us-east-1"  # AWS region
    path: "linea-stack"  # Path prefix in bucket
```

### Testing Backups Locally (MinIO)

You can test backups locally using MinIO (S3-compatible storage):

```bash
# Deploy MinIO in your cluster
kubectl create namespace minio
kubectl apply -f - <<EOF
apiVersion: v1
kind: Service
metadata:
  name: minio
  namespace: minio
spec:
  ports:
  - port: 9000
    targetPort: 9000
  selector:
    app: minio
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: minio
  namespace: minio
spec:
  replicas: 1
  selector:
    matchLabels:
      app: minio
  template:
    metadata:
      labels:
        app: minio
    spec:
      containers:
      - name: minio
        image: minio/minio:latest
        args:
        - server
        - /data
        - --console-address
        - ":9001"
        env:
        - name: MINIO_ROOT_USER
          value: "minioadmin"
        - name: MINIO_ROOT_PASSWORD
          value: "minioadmin"
        ports:
        - containerPort: 9000
        - containerPort: 9001
EOF

# Create bucket (via MinIO console or mc client)
# Access MinIO console: kubectl port-forward -n minio svc/minio 9001:9001
# Or use mc: kubectl run -it --rm mc --image=minio/mc --restart=Never -- sh
# Then: mc alias set local http://minio.minio:9000 minioadmin minioadmin
#       mc mb local/linea-backups

# Create backup credentials secret
kubectl create secret generic linea-stack-backup-credentials \
  --from-literal=AWS_ACCESS_KEY_ID=minioadmin \
  --from-literal=AWS_SECRET_ACCESS_KEY=minioadmin

# Configure values.yaml
# backup:
#   enabled: true
#   storage:
#     bucket: "linea-backups"
#     endpoint: "http://minio.minio:9000"
#     region: "us-east-1"

# Test backup manually (without waiting for schedule)
kubectl create job --from=cronjob/linea-stack-local-backup manual-backup-test

# Check backup job logs
kubectl logs job/manual-backup-test

# Verify backups in MinIO
kubectl port-forward -n minio svc/minio 9001:9001
# Visit http://localhost:9001 (login: minioadmin/minioadmin)
```

### Backup Features

- **Automated**: Runs on a configurable schedule (default: every 6 hours)
- **Compressed**: Tar.gz compression to reduce storage costs
- **Retention**: Automatically deletes old backups (keeps last N)
- **S3 Storage**: Backs up to AWS S3 or S3-compatible storage (MinIO, etc.)
- **Safe**: Read-only mounts, no impact on running pods
- **Testable Locally**: Can be tested with MinIO without AWS account

## Known Issues

**Maru Metrics**: Maru's metrics endpoint currently returns HTTP 500 with "Invalid registry: io.micrometer.core.instrument.composite.CompositeMeterRegistry". This is a known issue with the maru application's Micrometer registry initialization. Sequencer and Besu metrics are working correctly. Monitoring for maru can be done via logs until this is resolved in a future maru release.

**Besu Engine API Warning**: You may see warnings in Besu logs: `"Execution engine not called in 120 seconds, consensus client may not be connected"`. This is expected during initial sync or when Maru is still starting up. Besu has the Engine API enabled (port 8550) and expects calls from Maru (consensus client), but Maru will only start calling it once it's fully synced with the sequencer. This warning is harmless and should disappear once Maru completes its sync. Besu will continue to function correctly as an RPC node, syncing blocks from the sequencer via P2P.
