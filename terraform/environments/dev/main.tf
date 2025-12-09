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
