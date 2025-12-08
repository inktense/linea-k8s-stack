# Terraform for Linea 

This directory contains production-ready Terraform code for deploying AWS EKS clusters.

## Quick Start

### Prerequisites

1. **AWS CLI** configured with appropriate credentials
2. **Terraform** >= 1.0 installed
3. **S3 bucket** for remote state (use `scripts/create-bucket.sh`)

### Deploy to Development

```bash
# 1. Navigate to dev environment
cd environments/dev

# 2. Copy and customize variables
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values

# 3. Initialize Terraform
terraform init

# 4. Plan deployment
terraform plan

# 5. Apply changes
terraform apply
```


## 📦 Modules

### EKS Module (`modules/eks/`)

Minimal EKS module with only essential components:
- EKS cluster
- Managed node groups
- Essential add-ons (VPC CNI, CoreDNS, kube-proxy)
- Optional EBS CSI Driver for persistent volumes

**Usage:**
```hcl
module "eks" {
  source = "../../modules/eks"

  cluster_name = "my-eks-cluster"
  vpc_id = data.aws_vpc.default.id
  private_subnet_ids = local.default_subnet_ids
  # ... other variables
}
```

### VPC Configuration

The dev environment uses the **AWS default VPC** (via data sources) to save costs. No custom VPC module needed.

## 🌍 Environment

### Development (`environments/dev/`)

- **Purpose**: Testing and development
- **Cost Optimization**: Uses AWS default VPC (no VPC/NAT Gateway/Flow Logs charges)
- **VPC**: AWS default VPC (automatically provisioned in every AWS account)
- **Features**: Configurable logging and monitoring

## 🔐 State Management

Remote state is stored in S3:

- **State file**: `environments/dev/linea-k8s-stack.tfstate`

State files are stored in the S3 bucket configured in `backend.tf`.


## 🔧 Post-Deployment

After deploying, configure kubectl:

```bash
aws eks update-kubeconfig --name <cluster-name> --region <region>
```

Get the command from Terraform outputs:
```bash
terraform output kubectl_config_command
```


