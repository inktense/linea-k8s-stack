variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version to use for the EKS cluster"
  type        = string
  default     = "1.30"
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC where EKS will be deployed"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for EKS nodes"
  type        = list(string)
}

# Note: Removed optional features for minimal setup:
# - KMS encryption (not required for basic functionality)
# - Control plane logging (optional)
# - Private endpoint (public endpoint is sufficient)

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
}

# Note: Removed optional monitoring/autoscaling features for minimal setup

variable "enable_ebs_csi_driver" {
  description = "Enable EBS CSI Driver add-on for persistent volumes"
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

variable "tags" {
  description = "A map of tags to assign to the resource"
  type        = map(string)
  default     = {}
}

