# EKS Module

Reusable module for creating a production-ready EKS cluster with essential add-ons.

## Features

- EKS cluster with configurable Kubernetes version
- Managed node groups with auto-scaling
- KMS encryption for cluster secrets and node volumes
- Essential add-ons: VPC CNI, CoreDNS, kube-proxy
- EBS CSI Driver for persistent volumes (optional)
- Cluster Autoscaler support (requires Helm provider)
- CloudWatch Container Insights (optional)
- Control plane logging
- IRSA (IAM Roles for Service Accounts) support

## Usage

```hcl
module "eks" {
  source = "../../modules/eks"

  cluster_name = "my-eks-cluster"
  cluster_version = "1.28"
  environment = "prod"

  vpc_id              = module.vpc.vpc_id
  private_subnet_ids  = module.vpc.private_subnets

  node_groups = {
    general = {
      name           = "general"
      instance_types = ["t3.medium"]
      capacity_type  = "ON_DEMAND"
      min_size       = 2
      max_size       = 10
      desired_size   = 3
      disk_size      = 50
      disk_type      = "gp3"
      labels = {
        role = "general"
      }
      taints = []
    }
  }

  tags = {
    Environment = "prod"
  }
}
```

## Inputs

See `variables.tf` for all available variables.

## Outputs

See `outputs.tf` for all available outputs.

