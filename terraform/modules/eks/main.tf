module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  vpc_id     = var.vpc_id
  subnet_ids = var.private_subnet_ids

  # Only public access for minimal setup (saves on private endpoint costs)
  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = false

  cluster_addons = {
    vpc-cni = {
      most_recent = var.addon_vpc_cni_version == null
      version     = var.addon_vpc_cni_version
    }
    coredns = {
      most_recent = var.addon_coredns_version == null
      version     = var.addon_coredns_version
    }
    kube-proxy = {
      most_recent = var.addon_kube_proxy_version == null
      version     = var.addon_kube_proxy_version
    }
  }

  # Managed Node Groups
  eks_managed_node_groups = {
    for k, v in var.node_groups : v.name => {
      name            = "${var.cluster_name}-${v.name}"
      instance_types  = v.instance_types
      capacity_type   = v.capacity_type
      min_size        = v.min_size
      max_size        = v.max_size
      desired_size    = v.desired_size
      disk_size      = v.disk_size
      disk_type      = v.disk_type
      disk_encrypted = false  # Disable encryption to reduce costs

      labels = merge(
        v.labels,
        {
          Environment = var.environment
        }
      )

      taints = v.taints

      create_launch_template = true
      launch_template_name   = "${var.cluster_name}-${v.name}"

      # Basic IAM role configuration
      iam_role_additional_policies = {
        AmazonEC2ContainerRegistryReadOnly = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
      }

      subnet_ids = var.private_subnet_ids

      tags = merge(
        var.tags,
        {
          Name = "${var.cluster_name}-${v.name}-node"
        }
      )
    }
  }

  cluster_addons_timeouts = {
    create = "30m"
    update = "30m"
    delete = "15m"
  }

  tags = var.tags
}

# EBS CSI Driver IAM Role for Service Account
module "ebs_csi_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.0"

  count = var.enable_ebs_csi_driver ? 1 : 0

  role_name = "${var.cluster_name}-ebs-csi-driver"

  attach_ebs_csi_policy = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }

  tags = var.tags

  depends_on = [module.eks]
}

# EBS CSI Driver Add-on (created separately to avoid circular dependency)
resource "aws_eks_addon" "aws_ebs_csi_driver" {
  count = var.enable_ebs_csi_driver ? 1 : 0

  cluster_name             = module.eks.cluster_name
  addon_name               = "aws-ebs-csi-driver"
  addon_version            = var.addon_ebs_csi_driver_version
  service_account_role_arn = module.ebs_csi_irsa[0].iam_role_arn

  depends_on = [
    module.eks,
    module.ebs_csi_irsa
  ]

  tags = var.tags
}

