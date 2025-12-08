variable "aws_profile" {
  description = "AWS profile to use for authentication (optional, uses default if not set)"
  type        = string
  default     = ""
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "linea-eks-dev"
}

variable "region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "eu-west-2"
}

variable "cluster_version" {
  description = "Kubernetes version to use for the EKS cluster. Note: EBS CSI add-on requires version 1.31 or lower (as of 2024)."
  type        = string
  default     = "1.30"
}

variable "node_groups" {
  description = "Map of EKS managed node group definitions"
  type = map(object({
    name           = string
    instance_types = list(string)
    capacity_type  = string
    min_size       = number
    max_size       = number
    desired_size   = number
    disk_size      = number
    disk_type      = string
    labels         = map(string)
    taints = list(object({
      key    = string
      value  = string
      effect = string
    }))
  }))
  default = {
    general = {
      name           = "general"
      instance_types = ["t3.small"] 
      capacity_type  = "ON_DEMAND"
      min_size       = 1
      max_size       = 3
      desired_size   = 2 
      disk_size      = 30
      disk_type      = "gp3"
      labels = {
        role = "general"
      }
      taints = []
    }
  }
}

variable "enable_ebs_csi_driver" {
  description = "Enable EBS CSI Driver add-on for persistent volumes (needed for StatefulSets with persistent volumes)"
  type        = bool
  default     = true 
}

variable "addon_vpc_cni_version" {
  description = "Version of VPC CNI add-on"
  type        = string
  default     = null
}

variable "addon_coredns_version" {
  description = "Version of CoreDNS add-on"
  type        = string
  default     = null
}

variable "addon_kube_proxy_version" {
  description = "Version of kube-proxy add-on"
  type        = string
  default     = null
}

variable "addon_ebs_csi_driver_version" {
  description = "Version of EBS CSI Driver add-on"
  type        = string
  default     = null
}

variable "aws_auth_user_arn" {
  description = "AWS IAM user ARN to add to aws-auth ConfigMap for cluster access"
  type        = string
  default     = ""
}

variable "aws_auth_username" {
  description = "Username for the AWS IAM user in aws-auth ConfigMap"
  type        = string
  default     = ""
}

variable "tags" {
  description = "A map of tags to assign to the resource"
  type        = map(string)
  default = {
    Terraform   = "true"
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}

