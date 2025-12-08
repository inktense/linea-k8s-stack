provider "aws" {
  region = var.region

  default_tags {
    tags = merge(
      var.tags,
      {
        Cluster     = var.cluster_name
        Environment = "dev"
      }
    )
  }
}

data "aws_vpc" "default" {
  default = true
}

# Get all subnets from default VPC
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

locals {
  default_subnet_ids = data.aws_subnets.default.ids
}

resource "aws_ec2_tag" "subnet_tags" {
  for_each = {
    for subnet_id in local.default_subnet_ids : subnet_id => {
      id = subnet_id
    }
  }

  resource_id = each.value.id
  key         = "kubernetes.io/cluster/${var.cluster_name}"
  value       = "shared"
}

module "eks" {
  source = "../../modules/eks"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version
  environment     = "dev"

  vpc_id             = data.aws_vpc.default.id
  private_subnet_ids = local.default_subnet_ids

  node_groups = var.node_groups

  enable_ebs_csi_driver = var.enable_ebs_csi_driver

  addon_vpc_cni_version       = var.addon_vpc_cni_version
  addon_coredns_version       = var.addon_coredns_version
  addon_kube_proxy_version    = var.addon_kube_proxy_version
  addon_ebs_csi_driver_version = var.addon_ebs_csi_driver_version

  tags = merge(
    var.tags,
    {
      Environment = "dev"
    }
  )
}

# Create IAM Access Entry for the user (required for EKS authentication)
resource "aws_eks_access_entry" "serverless_admin" {
  cluster_name  = module.eks.cluster_name
  principal_arn = var.aws_auth_user_arn
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "serverless_admin" {
  cluster_name  = module.eks.cluster_name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = var.aws_auth_user_arn

  access_scope {
    type = "cluster"
  }

  depends_on = [aws_eks_access_entry.serverless_admin]
}

# Also add user to aws-auth ConfigMap
# Note: This requires AWS credentials that have access to the cluster (the IAM entity that created it)
resource "null_resource" "aws_auth" {
  triggers = {
    cluster_name     = module.eks.cluster_name
    user_arn         = var.aws_auth_user_arn
    username         = var.aws_auth_username
    cluster_endpoint = module.eks.cluster_endpoint
  }

  depends_on = [module.eks]

  provisioner "local-exec" {
    command = <<-EOT
      # Use AWS profile if specified
      if [ -n "${var.aws_profile}" ] && [ "${var.aws_profile}" != "" ]; then
        export AWS_PROFILE="${var.aws_profile}"
        echo "Using AWS profile: ${var.aws_profile}"
      fi
      
      # Update kubeconfig (uses AWS credentials from environment/profile)
      aws eks update-kubeconfig --name ${module.eks.cluster_name} --region ${var.region}
      
      # Get current aws-auth ConfigMap
      CURRENT_AUTH=$(kubectl get configmap aws-auth -n kube-system -o jsonpath='{.data.mapUsers}' 2>/dev/null || echo "")
      
      # Check if user already exists
      if echo "$CURRENT_AUTH" | grep -q "${var.aws_auth_user_arn}"; then
        echo "✓ User ${var.aws_auth_username} already exists in aws-auth"
        exit 0
      fi
      
      # Prepare new mapUsers content
      if [ -z "$CURRENT_AUTH" ] || [ "$CURRENT_AUTH" = "null" ]; then
        NEW_MAPUSERS="- userarn: ${var.aws_auth_user_arn}
  username: ${var.aws_auth_username}
  groups:
    - system:masters"
      else
        NEW_MAPUSERS="$CURRENT_AUTH
- userarn: ${var.aws_auth_user_arn}
  username: ${var.aws_auth_username}
  groups:
    - system:masters"
      fi
      
      # Update aws-auth ConfigMap
      kubectl patch configmap aws-auth -n kube-system --type merge -p "{\"data\":{\"mapUsers\":$(echo -n "$NEW_MAPUSERS" | python3 -c 'import sys, json; print(json.dumps(sys.stdin.read()))')}}" 2>/dev/null || \
      kubectl apply -f - <<EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapUsers: |
$NEW_MAPUSERS
EOF
      
      echo "✓ Added ${var.aws_auth_username} to aws-auth ConfigMap"
    EOT
  }
}

