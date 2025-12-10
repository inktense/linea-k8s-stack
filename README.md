# Linea Kubernetes Stack

A complete Kubernetes deployment for the Linea blockchain stack, including infrastructure provisioning and application deployment.

## Overview

This project provides:
- **Terraform** configuration for EKS cluster provisioning
- **Helm chart** for deploying the Linea stack (sequencer, maru, besu, ethstats, tx-sender)
- **Automated backups** to S3-compatible storage
- **Monitoring** integration with Prometheus

## Quick Start

### 1. Provision Infrastructure

See [terraform/README.md](terraform/README.md) for EKS cluster setup.

### 2. Deploy Linea Stack

See [helm/charts/linea-stack/README.md](helm/charts/linea-stack/README.md) for detailed deployment instructions.

```bash
# Create required secrets
kubectl create secret generic linea-stack-sequencer-p2p-key \
  --from-file=key=config/sequencer/key

kubectl create secret generic linea-stack-maru-p2p-key \
  --from-file=key=config/maru/key

kubectl create secret generic linea-stack-tx-sender-secrets \
  --from-literal=privateKey=0x... \
  --from-literal=toAddress=0x...

# Deploy the stack
helm upgrade --install local helm/charts/linea-stack
```

## Documentation

- **[Helm Chart Documentation](helm/charts/linea-stack/README.md)** - Complete deployment guide, configuration options, and component details
- **[Terraform Documentation](terraform/README.md)** - Infrastructure setup and EKS cluster provisioning
- **[EKS Module Documentation](terraform/modules/eks/README.md)** - EKS module reference
- **[Tx-Sender Documentation](tx-sender/README.md)** - Transaction sender service details

## Components

- **Sequencer**: Core blockchain sequencer node
- **Maru**: Linea consensus client
- **Besu**: Ethereum execution client with JSON-RPC
- **EthStats**: Network monitoring dashboard
- **Tx-Sender**: Automated transaction sender service

