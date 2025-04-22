variable "environment" {
  description = "Environment name"
  type        = string
}

variable "eks_cluster_id" {
  description = "ID of the EKS cluster"
  type        = string
}

variable "namespace" {
  description = "Kubernetes namespace for monitoring"
  type        = string
  default     = "monitoring"
}

variable "grafana_admin_password" {
  description = "Admin password for Grafana"
  type        = string
  default     = "admin123"  # Cambia esto en producción
  sensitive   = true
} 