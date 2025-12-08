# Destroying the EKS Cluster

Complete guide to cleanly destroy all resources created by Terraform.

## Prerequisites

1. Ensure you're using the correct AWS profile:
   ```bash
   export AWS_PROFILE=serverless-admin  # or your profile
   ```

2. Configure kubectl (if you want to clean up Helm releases first):
   ```bash
   aws eks update-kubeconfig --name linea-eks-dev --region eu-west-2
   ```

## Step-by-Step Destruction

### Step 1: Delete Helm Releases (Recommended)

Delete Helm releases to clean up Kubernetes resources and AWS LoadBalancers:

```bash
# List all Helm releases
helm list -A

# Delete Linea stack
helm uninstall linea-stack

# Delete Prometheus (if installed)
helm uninstall monitoring -n monitoring

# Verify all releases are deleted
helm list -A
```

**Wait 2-3 minutes** for LoadBalancers to be deleted before proceeding.

### Step 2: Verify Resources are Cleaned Up

```bash
# Check for any remaining LoadBalancers
kubectl get svc --all-namespaces | grep LoadBalancer

# Check for PersistentVolumes
kubectl get pv

# If LoadBalancers still exist, wait a bit longer or delete manually via AWS Console
```

### Step 3: Navigate to Terraform Directory

```bash
cd terraform/environments/dev
```

### Step 4: Review What Will Be Destroyed

```bash
terraform plan -destroy
```

**Review carefully!** This will show:
- EKS cluster deletion
- Node groups deletion
- IAM roles and policies
- All AWS resources

### Step 5: Destroy Infrastructure

```bash
terraform destroy
```

Terraform will ask for confirmation. Type `yes` to proceed.

**⏱️ This takes 10-15 minutes** to delete the EKS cluster and all resources.

### Step 6: Verify Destruction

```bash
# Verify cluster is deleted
aws eks describe-cluster --name linea-eks-dev --region eu-west-2
# Should return: "ResourceNotFoundException"

# Verify nodes are deleted
aws ec2 describe-instances --filters "Name=tag:eks:cluster-name,Values=linea-eks-dev" --region eu-west-2
# Should return empty or no matching instances
```

## Complete Command Sequence

Here's the complete sequence in one go:

```bash
# 1. Set AWS profile
export AWS_PROFILE=serverless-admin

# 2. Configure kubectl
aws eks update-kubeconfig --name linea-eks-dev --region eu-west-2

# 3. Delete Helm releases
helm uninstall linea-stack 2>/dev/null || echo "Linea stack not found"
helm uninstall monitoring -n monitoring 2>/dev/null || echo "Prometheus not found"

# 4. Wait for LoadBalancers to delete (optional but recommended)
echo "Waiting 30 seconds for LoadBalancers to be deleted..."
sleep 30

# 5. Navigate to Terraform directory
cd terraform/environments/dev

# 6. Destroy infrastructure
terraform destroy

# 7. Verify (optional)
aws eks list-clusters --region eu-west-2 | grep linea-eks-dev || echo "Cluster deleted successfully"
```

## What Gets Deleted

When you run `terraform destroy`, it will delete:

✅ **EKS Cluster**
- Control plane
- All add-ons (VPC-CNI, CoreDNS, kube-proxy, EBS CSI)
- IAM roles and policies
- Security groups

✅ **Node Groups**
- EC2 instances
- Launch templates
- Auto Scaling groups

✅ **IAM Resources**
- EKS access entries
- IRSA roles (EBS CSI)

✅ **Other Resources**
- VPC subnet tags
- CloudWatch log groups (if any)

## What Might NOT Be Deleted

⚠️ **Orphaned Resources** (if Helm releases weren't deleted first):
- LoadBalancers (from services)
- EBS volumes (if retention policy is set)
- S3 buckets (if backups were configured)

**To clean up manually:**
```bash
# List LoadBalancers
aws elbv2 describe-load-balancers --region eu-west-2 --query 'LoadBalancers[?contains(LoadBalancerName, `k8s`)].LoadBalancerName'

# List EBS volumes
aws ec2 describe-volumes --region eu-west-2 --filters "Name=tag:kubernetes.io/cluster/linea-eks-dev,Values=owned" --query 'Volumes[*].VolumeId'
```

## Troubleshooting

### Error: "Cluster is not empty"

If you get an error that the cluster still has resources:

```bash
# Check for remaining resources
kubectl get all --all-namespaces

# Force delete if needed (be careful!)
kubectl delete namespace <namespace> --force --grace-period=0
```

### Error: "Cannot delete node group"

If node group deletion fails:

```bash
# Manually delete via AWS CLI
aws eks delete-nodegroup \
  --cluster-name linea-eks-dev \
  --nodegroup-name linea-eks-dev-general \
  --region eu-west-2

# Then retry terraform destroy
terraform destroy
```

### Error: "LoadBalancer still exists"

If LoadBalancers prevent cluster deletion:

1. Go to AWS Console → EC2 → Load Balancers
2. Find LoadBalancers with `k8s-` prefix
3. Delete them manually
4. Retry `terraform destroy`

## Quick Destroy (Skip Helm Cleanup)

If you just want to destroy everything quickly (may leave orphaned resources):

```bash
cd terraform/environments/dev
terraform destroy
```

This will delete the cluster, and orphaned LoadBalancers/EBS volumes will be cleaned up manually later.

## Cost Savings

After destruction:
- **EKS cluster**: $0/hour (deleted)
- **EC2 nodes**: $0/hour (deleted)
- **Total savings**: ~$100-120/month

⚠️ **Remember**: Orphaned LoadBalancers (~$18/month each) and EBS volumes (~$0.10/GB/month) will continue to cost money if not deleted.

